#!/usr/bin/env bash
#-----------------------------------------------------------------------
#          File: install.sh
#   Description: Dotfile installer with OS/arch detection (Linux, macOS Intel/ARM)
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.1.0
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2026-04-24
#       Lastmod: 2026-10-13
#-----------------------------------------------------------------------

set -euo pipefail

REPO_SLUG="aamnah/dotfiles"
REPO_BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO_SLUG/$REPO_BRANCH"

MODE="local"

# Defaults for the install questions. Used as-is with -y, or when there's
# no terminal to ask on (Docker builds, CI).
DEFAULT_SHELL="zsh"
DEFAULT_LOCALE="en_US.UTF-8"
DEFAULT_FONT="Hasklig"       # Nerd Font archive name; "Hasklig" installs as "Hasklug Nerd Font"

# Nerd Fonts release to download fonts from. Pinned (not "latest") so every
# install gets the same, tested files. To update: pick a newer tag from
# https://github.com/ryanoasis/nerd-fonts/releases and re-test.
NERD_FONTS_VERSION="v3.5.1"

# Answers — set by flags (--shell=, --locale=) or by the prompts.
# Empty = not decided yet, ask_questions fills them in.
SHELL_CHOICE=""   # zsh | bash | keep (don't change the login shell)
LOCALE=""         # UTF-8 locale to generate and save, e.g. en_US.UTF-8
FONT_CHOICE=""    # Nerd Font archive name (Hasklig, FiraCode…) or "none"
ASSUME_YES=0      # 1 = -y: accept defaults, never prompt

for arg in "$@"; do
    case "$arg" in
        --remote) MODE="remote" ;;
        -y|--yes) ASSUME_YES=1 ;;
        --shell=*) SHELL_CHOICE="${arg#--shell=}" ;;
        --locale=*) LOCALE="${arg#--locale=}" ;;
        --font=*) FONT_CHOICE="${arg#--font=}" ;;
        -h|--help)
            cat <<EOF
Usage: install.sh [--remote] [-y] [--shell=zsh|bash|keep] [--locale=LOCALE] [--font=FONT]

  (default)        Copy configs from this checkout to \$HOME, asking a few
                   questions first (login shell, locale, font).
  --remote         Fetch configs from $RAW_BASE and install to \$HOME (no clone needed).
  -y, --yes        Don't ask — use defaults (or the values from the flags below).
  --shell=SHELL    Login shell: zsh (default), bash, or keep (leave it as is).
                   Configs for both zsh and bash are always installed.
  --locale=LOCALE  UTF-8 locale to generate and use, e.g. ja_JP.UTF-8
                   (default: $DEFAULT_LOCALE). Saved to ~/.config/locale.conf.
  --font=FONT      Nerd Font for the terminal (desktops only): Hasklig (default,
                   "Hasklug"), JetBrainsMono, FiraCode, Meslo, CascadiaCode,
                   Hack, or none.

Example (fresh VPS, no questions):
  curl -fsSL $RAW_BASE/install.sh | bash -s -- --remote -y
EOF
            exit 0
            ;;
        *)
            echo "error: unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

if [[ "$MODE" == "remote" ]]; then
    if ! command -v curl >/dev/null 2>&1; then
        echo "error: --remote requires curl" >&2
        exit 1
    fi
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    echo "mode: remote ($RAW_BASE)"
else
    echo "mode: local ($REPO_DIR)"
fi

# Resolve a repo-relative path to a local file.
# Local mode: returns the path inside the checkout.
# Remote mode: downloads the file to a tempdir and returns that path.
# On remote fetch failure, the returned path will not exist — the caller's
# `[[ -f "$src" ]]` check surfaces the error.
fetch_source() {
    local rel="$1"
    if [[ "$MODE" == "local" ]]; then
        echo "$REPO_DIR/$rel"
        return 0
    fi
    local url="$RAW_BASE/$rel"
    local dest="$TMP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    echo "fetching: $url" >&2
    if ! curl -fsSL "$url" -o "$dest"; then
        echo "error: failed to fetch $url" >&2
    fi
    echo "$dest"
}

detect_system() {
    case "$(uname -s)" in
        Linux)
            SYSTEM="linux"
            NANO_SHARE="/usr/share/nano"
            ;;
        Darwin)
            case "$(uname -m)" in
                arm64)
                    SYSTEM="macos-arm"
                    NANO_SHARE="/opt/homebrew/share/nano"
                    ;;
                x86_64)
                    SYSTEM="macos-intel"
                    NANO_SHARE="/usr/local/share/nano"
                    ;;
                *)
                    echo "error: unsupported macOS architecture: $(uname -m)" >&2
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "error: unsupported OS: $(uname -s)" >&2
            exit 1
            ;;
    esac

    # Package manager used by pkg_install. Detected once here so every
    # ensure_* function shares the same logic. Empty = none found.
    # On macOS only brew counts — Linuxbrew is ignored on Linux so system
    # packages go through the distro's own manager.
    PKG_MGR=""
    if [[ "$SYSTEM" == macos-* ]]; then
        command -v brew >/dev/null 2>&1 && PKG_MGR="brew"
    else
        local m
        for m in apt-get dnf yum pacman zypper apk; do
            if command -v "$m" >/dev/null 2>&1; then
                PKG_MGR="${m%-get}"  # apt-get -> apt
                break
            fi
        done
    fi

    echo "detected: $SYSTEM (package manager: ${PKG_MGR:-none})"
}

backup_if_exists() {
    local dest="$1"
    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        echo "backing up $dest -> $backup"
        mv "$dest" "$backup"
    fi
}

#-----------------------------------------------------------------------
# Install questions
#-----------------------------------------------------------------------

# True when a keyboard is reachable.
# Reads go to /dev/tty, not stdin — with `curl … | bash` stdin IS the
# script, so a plain `read` would eat the next line of the script as the
# answer. Opening /dev/tty is the real test: in Docker/CI the file exists
# but can't be opened.
has_tty() {
    { : </dev/tty; } 2>/dev/null
}

# True when we should ask questions: not -y, and a keyboard is reachable
can_prompt() {
    [[ "$ASSUME_YES" -eq 0 ]] && has_tty
}

# Numbered menu. Stores the chosen option's text in REPLY_CHOICE.
# Enter picks the default; anything invalid asks again.
# Usage: ask_choice "<question>" <default-number> <option>...
REPLY_CHOICE=""
ask_choice() {
    local question="$1" default="$2"; shift 2
    local options=("$@") i ans mark
    printf '\n%s\n' "$question" >/dev/tty
    for i in "${!options[@]}"; do
        mark=""
        [[ $((i + 1)) -eq "$default" ]] && mark="  (default)"
        printf '  %d) %s%s\n' $((i + 1)) "${options[i]}" "$mark" >/dev/tty
    done
    while true; do
        printf 'Choose [%d]: ' "$default" >/dev/tty
        read -r ans </dev/tty || ans=""   # Ctrl-D counts as Enter
        ans="${ans:-$default}"
        if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 && ans <= ${#options[@]} )); then
            REPLY_CHOICE="${options[ans - 1]}"
            return 0
        fi
        printf 'Please enter a number from 1 to %d.\n' "${#options[@]}" >/dev/tty
    done
}

# Turn ja_JP / ja_JP.utf8 / ja_JP.UTF-8 into ja_JP.UTF-8.
# Returns 1 (prints nothing) if it doesn't look like a locale name.
# Always UTF-8: the shell configs and tools assume it.
normalize_locale() {
    local base="${1%%.*}"
    local re='^[a-z]{2,3}_[A-Z]{2}$'
    [[ "$base" =~ $re ]] || return 1
    echo "$base.UTF-8"
}

# Nerd Fonts offered by the installer. A "Nerd Font" is a programming font
# with thousands of icons added (git branch, folder, OS logos…) that prompts,
# tmux status bars and editors use. Without one, those icons show as boxes.
#
# nerd_font_archive: turn what the user typed or picked into the archive
#   name used on the Nerd Fonts download page (e.g. "hasklug" → Hasklig).
#   Prints nothing for an unknown font.
# The archive name and the installed font name sometimes differ: Hasklig is
# installed as "Hasklug", CascadiaCode as "CaskaydiaCove" (the originals'
# licences don't allow modified copies under the same name).
nerd_font_archive() {
    case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ')" in
        hasklig|hasklug*)       echo Hasklig ;;
        jetbrainsmono*)         echo JetBrainsMono ;;
        firacode*)              echo FiraCode ;;
        meslo*)                 echo Meslo ;;
        cascadia*|caskaydia*)   echo CascadiaCode ;;
        hack*)                  echo Hack ;;
        none*|skip*)            echo none ;;
    esac
}

# nerd_font_family: the font name apps see once it's installed — what
# kitty.conf's font_family needs. "Mono" = every icon is one character
# wide, so columns stay aligned in a terminal.
nerd_font_family() {
    case "$1" in
        Hasklig)        echo "Hasklug Nerd Font Mono" ;;
        JetBrainsMono)  echo "JetBrainsMono Nerd Font Mono" ;;
        FiraCode)       echo "FiraCode Nerd Font Mono" ;;
        Meslo)          echo "MesloLGS Nerd Font Mono" ;;
        CascadiaCode)   echo "CaskaydiaCove Nerd Font Mono" ;;
        Hack)           echo "Hack Nerd Font Mono" ;;
    esac
}

# Fill in SHELL_CHOICE and LOCALE. Flags win; prompts cover the rest;
# defaults are used with -y or when there's no terminal.
ask_questions() {
    # Validate flags first, so a typo fails before anything is changed
    case "$SHELL_CHOICE" in
        ""|zsh|bash|keep) ;;
        *)
            echo "error: --shell must be zsh, bash or keep (got: $SHELL_CHOICE)" >&2
            exit 1
            ;;
    esac
    if [[ -n "$FONT_CHOICE" ]]; then
        local given_font="$FONT_CHOICE"
        FONT_CHOICE="$(nerd_font_archive "$given_font")"
        if [[ -z "$FONT_CHOICE" ]]; then
            echo "error: --font must be Hasklig, JetBrainsMono, FiraCode, Meslo, CascadiaCode, Hack or none (got: $given_font)" >&2
            exit 1
        fi
    fi
    # Fonts only matter on the machine you look at: on a VPS or in a
    # container the terminal (and its font) is on your own computer
    if ! is_desktop; then
        FONT_CHOICE="none"
    fi
    if [[ -n "$LOCALE" ]]; then
        local given="$LOCALE"
        if ! LOCALE="$(normalize_locale "$given")"; then
            echo "error: --locale must look like en_US or en_US.UTF-8 (got: $given)" >&2
            exit 1
        fi
    fi

    if ! can_prompt; then
        SHELL_CHOICE="${SHELL_CHOICE:-$DEFAULT_SHELL}"
        LOCALE="${LOCALE:-$DEFAULT_LOCALE}"
        FONT_CHOICE="${FONT_CHOICE:-$DEFAULT_FONT}"
        return 0
    fi

    if [[ -z "$SHELL_CHOICE" ]]; then
        # zsh is the default for everyone. "keep" only appears when the
        # current login shell is something else (fish, tcsh…), so those
        # users can install the configs without being moved off it.
        local current; current="$(basename "${SHELL:-}")"
        local opts=("zsh" "bash")
        if [[ -n "$current" && "$current" != "zsh" && "$current" != "bash" ]]; then
            opts+=("keep $current")
        fi
        ask_choice "Login shell? (configs for both zsh and bash are installed either way)" 1 "${opts[@]}"
        SHELL_CHOICE="${REPLY_CHOICE%% *}"   # "keep fish" -> keep
    fi

    if [[ -z "$LOCALE" ]]; then
        ask_choice "Locale? (language and formats for dates, numbers, sorting)" 1 \
            "$DEFAULT_LOCALE" "en_GB.UTF-8" "other (type it, e.g. ja_JP.UTF-8)"
        if [[ "$REPLY_CHOICE" == other* ]]; then
            local typed
            while true; do
                printf 'Locale: ' >/dev/tty
                # Ctrl-D gives up and uses the default instead of looping forever
                read -r typed </dev/tty || { LOCALE="$DEFAULT_LOCALE"; break; }
                LOCALE="$(normalize_locale "$typed")" && break
                printf "That doesn't look like a locale. Use the form ja_JP or ja_JP.UTF-8.\n" >/dev/tty
            done
        else
            LOCALE="$REPLY_CHOICE"
        fi
    fi

    if [[ -z "$FONT_CHOICE" ]]; then
        ask_choice "Terminal font? (a Nerd Font, so prompt and tmux icons show instead of boxes)" 1 \
            "Hasklug" "JetBrains Mono" "Fira Code" "Meslo" "Caskaydia Cove" "Hack" "none (skip)"
        FONT_CHOICE="$(nerd_font_archive "$REPLY_CHOICE")"
    fi
}

# Show what's about to happen and ask before changing anything.
# With -y or no terminal it just prints the plan and continues.
confirm_plan() {
    local shell_line="$SHELL_CHOICE"
    [[ "$SHELL_CHOICE" == "keep" ]] && shell_line="keep current (${SHELL:-unknown})"
    local font_line="$(nerd_font_family "$FONT_CHOICE")"
    [[ "$FONT_CHOICE" == "none" ]] && font_line="none (skipped$(is_desktop || echo ': not a desktop'))"

    cat <<PLAN

Plan:
  login shell  $shell_line
  locale       $LOCALE (saved to $HOME/.config/locale.conf)
  font         $font_line
  configs      nano, tmux, kitty, nvim, starship, zsh, bash
               (existing files are backed up as <file>.bak.<timestamp>)
  source       $MODE
PLAN

    can_prompt || return 0
    local ans
    printf '\nProceed? [Y/n] ' >/dev/tty
    read -r ans </dev/tty || ans=""
    case "$ans" in
        ""|y|Y|yes|Yes|YES) ;;
        *)
            echo "aborted — nothing was changed"
            exit 0
            ;;
    esac
}

# Save the chosen locale to ~/.config/locale.conf. .zshenv and
# .bash_profile read LANG from it; without it they use en_US.UTF-8.
# Same file and format Arch's /etc/profile.d/locale.sh reads.
write_locale_conf() {
    local dest="$HOME/.config/locale.conf"
    if [[ -f "$dest" ]] && grep -qx "LANG=$LOCALE" "$dest"; then
        echo "found: $dest (LANG=$LOCALE)"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    printf 'LANG=%s\n' "$LOCALE" > "$dest"
    echo "installed: $dest (LANG=$LOCALE)"
}

# Make $SHELL_CHOICE the login shell (the one you get on login/SSH).
# Never fails the script: on any problem it prints the manual command.
set_login_shell() {
    [[ "$SHELL_CHOICE" == "keep" ]] && return 0

    local shell_path
    if ! shell_path="$(command -v "$SHELL_CHOICE")"; then
        echo "warning: $SHELL_CHOICE not installed — login shell not changed" >&2
        return 0
    fi

    # Prefer the path /etc/shells already lists. command -v can return an
    # odd but valid path — Fedora merged /usr/sbin into /usr/bin, so it
    # finds /usr/sbin/zsh — which would otherwise get added to /etc/shells.
    if [[ -f /etc/shells ]]; then
        local listed
        while read -r listed; do
            if [[ "$listed" == /* && "$(basename "$listed")" == "$SHELL_CHOICE" && -x "$listed" ]]; then
                shell_path="$listed"
                break
            fi
        done < /etc/shells
    fi

    # Compare names, not paths: /bin/zsh and /usr/bin/zsh are the same
    # file on most distros. getent reads the real login shell from the
    # user database; $SHELL is the fallback (macOS has no getent).
    local user current
    user="$(id -un)"
    current="$(getent passwd "$user" 2>/dev/null | cut -d: -f7)" || true
    current="${current:-${SHELL:-}}"
    if [[ "$(basename "$current")" == "$SHELL_CHOICE" ]]; then
        echo "found: login shell is already $SHELL_CHOICE"
        return 0
    fi

    # chsh isn't in every minimal image: Fedora keeps it in
    # util-linux-user, Alpine in shadow (BusyBox doesn't have one)
    if ! command -v chsh >/dev/null 2>&1; then
        case "$PKG_MGR" in
            dnf|yum) pkg_install util-linux-user || true ;;
            apk)     pkg_install shadow || true ;;
        esac
    fi
    if ! command -v chsh >/dev/null 2>&1; then
        echo "warning: chsh not found — set your login shell to $shell_path manually" >&2
        return 0
    fi

    # chsh only accepts shells listed in /etc/shells. Homebrew's zsh isn't
    # there by default (fix from the Oh My Zsh install guide).
    if [[ -f /etc/shells ]] && ! grep -qx "$shell_path" /etc/shells; then
        echo "$shell_path" | as_root tee -a /etc/shells >/dev/null || true
    fi

    # As root (Docker) chsh needs no password. Otherwise it asks for yours,
    # read from /dev/tty so it works under curl | bash too.
    echo "setting login shell: $shell_path"
    if [[ "$(id -u)" -eq 0 ]]; then
        chsh -s "$shell_path" "$user" || { echo "warning: chsh failed — run: chsh -s $shell_path" >&2; return 0; }
    elif has_tty; then
        chsh -s "$shell_path" </dev/tty || { echo "warning: chsh failed — run: chsh -s $shell_path" >&2; return 0; }
    else
        echo "note: no terminal to ask for your password — run: chsh -s $shell_path" >&2
        return 0
    fi
    echo "note: log out and back in for the new login shell to take effect"
}

# True on a machine with a graphical session — i.e. one you sit in front
# of, as opposed to a VPS or container you SSH into. Used to skip things
# only useful on a desktop (GUI apps, notifications).
# macOS always counts. On Linux, DISPLAY (X11) or WAYLAND_DISPLAY is set
# by the graphical session; both are empty over plain SSH and in Docker.
is_desktop() {
    [[ "$SYSTEM" == macos-* || -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]
}

# Servers you SSH into from kitty receive TERM=xterm-kitty. Without
# kitty's terminfo entry (its description of what the terminal can do),
# nano, htop, less and clear fail with "unknown terminal type".
# kitty itself bundles it, so this is only needed where kitty isn't
# installed. Skipped on macOS — that's the client side, not a server.
ensure_kitty_terminfo() {
    [[ "$SYSTEM" == macos-* ]] && return 0
    command -v kitty >/dev/null 2>&1 && return 0

    # Checks files, not `infocmp`: Fedora and Alpine images don't ship it
    local d
    for d in /usr/share/terminfo /lib/terminfo /usr/lib/terminfo /etc/terminfo; do
        if [[ -e "$d/x/xterm-kitty" ]]; then
            echo "found: kitty terminfo"
            return 0
        fi
    done

    echo "installing: kitty terminfo"
    pkg_install kitty-terminfo \
        || echo "warning: failed to install kitty-terminfo — connect with 'kitten ssh <host>' instead, it copies the terminfo over" >&2
}

# Install the chosen Nerd Font for the current user (no sudo needed).
# Desktops only — FONT_CHOICE is "none" elsewhere (see ask_questions).
# Never fails the script: on any problem it warns and returns.
ensure_nerd_font() {
    [[ "$FONT_CHOICE" == "none" || -z "$FONT_CHOICE" ]] && return 0

    local family; family="$(nerd_font_family "$FONT_CHOICE")"
    # Font files are named without spaces, e.g. HasklugNerdFontMono-Regular.ttf
    local file_prefix="${family// /}"
    file_prefix="${file_prefix%Mono}"   # match the Mono and non-Mono files

    # Where fonts for one user go. Linux: any folder under ~/.local/share/fonts
    # is picked up by fontconfig (the font finder most Linux apps use).
    local font_dir
    if [[ "$SYSTEM" == macos-* ]]; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts/${FONT_CHOICE}NerdFont"
    fi

    # Already installed? fc-list lists every font fontconfig knows (Linux);
    # on macOS (no fontconfig) look for the files themselves.
    # Why `grep … >/dev/null` and not `grep -q`: -q quits at the first match,
    # and fc-list, still writing its long list, then gets SIGPIPE ("nobody is
    # reading any more") and fails. With `set -o pipefail` (top of this
    # script) that failure makes the whole check false — "not installed"
    # exactly when it IS installed. Reading everything avoids that.
    if { command -v fc-list >/dev/null 2>&1 && fc-list : family | grep -i "$family" >/dev/null; } ||
       compgen -G "$font_dir/${file_prefix}*" >/dev/null; then
        echo "found: $family"
        return 0
    fi

    # The download is a .tar.xz archive; tar needs the xz tool to unpack it.
    # macOS's tar has it built in; minimal Linux installs may not.
    if [[ "$SYSTEM" == linux ]] && ! command -v xz >/dev/null 2>&1; then
        case "$PKG_MGR" in
            apt) pkg_install xz-utils ;;
            *)   pkg_install xz ;;
        esac || { echo "warning: can't unpack the font without xz — font not installed" >&2; return 0; }
    fi

    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$FONT_CHOICE.tar.xz"
    local download_dir; download_dir="$(mktemp -d)"
    echo "installing font: $family"
    if ! curl -fsSL "$url" -o "$download_dir/font.tar.xz"; then
        echo "warning: font download failed ($url) — font not installed" >&2
        rm -rf "$download_dir"
        return 0
    fi
    mkdir -p "$font_dir"
    # -x extract, -J the archive is xz-compressed, -f the file to read,
    # -C unpack into this folder. Only the font files are kept.
    tar -xJf "$download_dir/font.tar.xz" -C "$download_dir" &&
        cp "$download_dir"/*.[ot]tf "$font_dir"/
    rm -rf "$download_dir"

    # Refresh fontconfig's list of fonts so apps find the new one right away
    # (otherwise only after a re-login). macOS notices new fonts by itself.
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$font_dir" >/dev/null 2>&1
    echo "installed: $family -> $font_dir"
}

install_nano() {
    local src; src="$(fetch_source ".config/nano/nanorc")"
    local dest="$HOME/.nanorc"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if [[ "$SYSTEM" == macos-* ]]; then
        if ! command -v nano >/dev/null 2>&1 || ! nano --version 2>/dev/null | grep 'GNU nano' >/dev/null; then
            echo "warning: macOS ships an old nano (2.0.6). Install a modern one with: brew install nano" >&2
        fi
    fi

    if [[ ! -d "$NANO_SHARE" ]]; then
        echo "warning: $NANO_SHARE does not exist — syntax highlighting may not load" >&2
    fi

    backup_if_exists "$dest"
    sed "s|/usr/share/nano/\*\.nanorc|$NANO_SHARE/*.nanorc|g" "$src" > "$dest"
    echo "installed: $dest (syntax dir: $NANO_SHARE)"
}

install_git_repo() {
    local name="$1"
    local url="$2"
    local dest="$3"
    local branch="${4:-}"

    if [[ -d "$dest/.git" ]]; then
        echo "installed: $dest ($name already present)"
        return 0
    fi

    if [[ -e "$dest" ]]; then
        echo "warning: $name not installed — $dest exists but is not a git checkout" >&2
        return 0
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo "warning: $name not installed — git not found. Install git, then run:" >&2
        if [[ -n "$branch" ]]; then
            echo "         git clone -b $branch $url $dest" >&2
        else
            echo "         git clone $url $dest" >&2
        fi
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    echo "installing: $name -> $dest"
    if [[ -n "$branch" ]]; then
        git clone --depth 1 -b "$branch" "$url" "$dest"
    else
        git clone --depth 1 "$url" "$dest"
    fi
}

install_tmux() {
    local files=(
        ".tmux.conf"
        ".config/tmux/tmux.conf"
        ".config/tmux/reset.tmux"
        ".config/tmux/lasik.tmux"
        ".config/tmux/catppuccin.tmux"
    )

    if ! command -v tmux >/dev/null 2>&1; then
        if [[ "$SYSTEM" == macos-* ]]; then
            echo "warning: tmux not found. Install with: brew install tmux" >&2
        else
            echo "warning: tmux not found. Install with your package manager (e.g. apt install tmux)" >&2
        fi
    fi

    if [[ -e "$HOME/.config/tmux" && ! -d "$HOME/.config/tmux" ]]; then
        echo "error: $HOME/.config/tmux exists but is not a directory" >&2
        return 1
    fi
    mkdir -p "$HOME/.config/tmux"

    for f in "${files[@]}"; do
        local src; src="$(fetch_source "$f")"
        local dest="$HOME/$f"

        if [[ ! -f "$src" ]]; then
            echo "error: $src not found" >&2
            continue
        fi

        mkdir -p "$(dirname "$dest")"
        backup_if_exists "$dest"
        cp "$src" "$dest"
        echo "installed: $dest"
    done

    install_git_repo \
        "TPM" \
        "https://github.com/tmux-plugins/tpm" \
        "$HOME/.config/tmux/plugins/tpm"

    install_git_repo \
        "Catppuccin tmux plugin" \
        "https://github.com/catppuccin/tmux.git" \
        "$HOME/.config/tmux/plugins/catppuccin/tmux" \
        "v2.3.0"
}

install_kitty() {
    local src; src="$(fetch_source ".config/kitty/kitty.conf")"
    local dest="$HOME/.config/kitty/kitty.conf"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    # Desktops only: kitty is a GUI app that runs on the machine you type
    # on. On a VPS it'd never be used — you SSH in from your local kitty —
    # so the warning there is just noise. The config is still copied.
    if is_desktop && ! command -v kitty >/dev/null 2>&1; then
        if [[ "$SYSTEM" == macos-* ]]; then
            echo "warning: kitty not found. Install with: brew install --cask kitty" >&2
        else
            echo "warning: kitty not found. Install from https://sw.kovidgoyal.net/kitty/binary/ or your package manager" >&2
        fi
    fi

    ensure_kitty_terminfo

    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    # kitty.conf names Hasklug as its font. If another Nerd Font was chosen,
    # put that font's name in while copying (same idea as nano's paths) —
    # otherwise kitty would look for a font that isn't installed.
    local family; family="$(nerd_font_family "$FONT_CHOICE")"
    if [[ -n "$family" && "$FONT_CHOICE" != "$DEFAULT_FONT" ]]; then
        sed "s|^font_family .*|font_family      $family|" "$src" > "$dest"
    else
        cp "$src" "$dest"
    fi
    echo "installed: $dest${family:+ (font: $family)}"
}

install_starship() {
    local src; src="$(fetch_source ".config/starship.toml")"
    local dest="$HOME/.config/starship.toml"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if ! command -v starship >/dev/null 2>&1; then
        echo "starship not found, installing..."
        if [[ "$SYSTEM" == macos-* ]] && command -v brew >/dev/null 2>&1; then
            brew install starship
        elif command -v curl >/dev/null 2>&1; then
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
        else
            echo "warning: cannot install starship — install curl or brew, then re-run" >&2
        fi
    fi

    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    cp "$src" "$dest"
    echo "installed: $dest"

    # Theme files. kitty.conf loads themes/lasik.conf — without these, kitty
    # silently falls back to its default colours. Listed by name (not the
    # whole folder) because --remote fetches files one by one and can't list
    # a folder on GitHub. Add new themes here.
    install_home_files \
        .config/kitty/themes/lasik.conf \
        .config/kitty/themes/catppucin-mocha.conf
}

install_nvim() {
    local src; src="$(fetch_source ".config/nvim/init.lua")"
    local dest="$HOME/.config/nvim/init.lua"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if ! command -v nvim >/dev/null 2>&1; then
        if [[ "$SYSTEM" == macos-* ]]; then
            echo "warning: nvim not found. Install with: brew install neovim" >&2
        else
            echo "warning: nvim not found. Install with your package manager (e.g. apt install neovim)" >&2
        fi
    fi

    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    cp "$src" "$dest"
    echo "installed: $dest"
}

# Run a command as root: directly if we already are, else through sudo.
# Docker containers often run as root with no sudo installed, so sudo is
# only added when needed. Returns 1 (with a warning) if neither works.
# Usage: as_root <command> [args...]
as_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "warning: cannot run '$1' — not root and sudo not found" >&2
        return 1
    fi
}

# Install packages with $PKG_MGR (set by detect_system).
# Commands follow https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
# Returns non-zero on failure — callers warn and carry on, so a failed
# package install never stops the config files from being installed.
# Usage: pkg_install <package>...
APT_UPDATED=""
pkg_install() {
    case "$PKG_MGR" in
        apt)
            # update first: fresh Debian/Ubuntu images ship with empty package
            # lists, so install would fail with "Unable to locate package".
            # Only once per run — it's slow and the lists don't change mid-run.
            if [[ -z "$APT_UPDATED" ]]; then
                as_root apt-get update || return 1
                APT_UPDATED=1
            fi
            # noninteractive: some packages (locales, tzdata) can open a
            # full-screen config dialog mid-install and hang the script.
            # Passed through env because sudo drops most env vars.
            as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
            ;;
        dnf)    as_root dnf install -y "$@" ;;
        yum)    as_root yum -y install "$@" ;;
        pacman)
            # Fresh Arch images have no package database (like apt's empty
            # lists), so every install fails with "target not found".
            # Synced with -Syu, not -Sy: Arch doesn't support partial
            # upgrades — installing from a newer database than the system
            # can break it. Only when the database is missing, so a real
            # machine never gets a full upgrade behind your back.
            if ! compgen -G "/var/lib/pacman/sync/*.db" >/dev/null; then
                as_root pacman -Syu --noconfirm || return 1
            fi
            as_root pacman -S --noconfirm --needed "$@"
            ;;
        zypper) as_root zypper --non-interactive install "$@" ;;
        apk)    as_root apk add "$@" ;;
        # brew refuses to run as root, so it never goes through as_root
        brew)   brew install "$@" ;;
        *)
            if [[ "$SYSTEM" == macos-* ]]; then
                echo "warning: cannot install $* — install Homebrew, then run: brew install $*" >&2
            else
                echo "warning: cannot install $* — no supported package manager found" >&2
            fi
            return 1
            ;;
    esac
}

# Install the zsh binary if it's missing.
# Without this, a fresh VPS/Docker box gets the zsh configs copied over but
# has no shell to read them.
# Never fails the script: on any problem it warns and returns, so the
# config files still get installed.
ensure_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "found: $(zsh --version)"
        return 0
    fi

    # On macOS zsh ships by default (Catalina and later), so this only
    # triggers on very old macOS or a stripped-down system
    echo "zsh not found, installing..."
    if ! pkg_install zsh; then
        echo "warning: zsh install failed — install it manually" >&2
        return 0
    fi

    # Installing zsh doesn't make it the login shell — set_login_shell does that
    if command -v zsh >/dev/null 2>&1; then
        echo "installed: $(zsh --version)"
    fi
}

# Install CLI tools the shell configs rely on, if missing:
#   less            — pager; .bash_profile/.zshrc hook lesspipe into it
#   bash-completion — sourced by .bash_profile for Tab completion
#   notify-send     — used by the `alert` alias in .aliases
# Ubuntu Desktop ships all three and Ubuntu Server ships less +
# bash-completion, but Docker images (ubuntu, debian, fedora) have none.
# Without them the configs still load (every use is guarded), the features
# are just silently missing.
ensure_shell_tools() {
    # macOS: less ships with the OS. bash-completion is skipped — Homebrew's
    # version needs bash 4+, macOS ships 3.2 and defaults to zsh anyway.
    # notify-send is Linux-only, so `alert` simply isn't defined there.
    if [[ "$SYSTEM" == macos-* ]]; then
        return 0
    fi

    local pkgs=()
    command -v less >/dev/null 2>&1 || pkgs+=(less)

    # Checks the same paths .bash_profile sources, not a command — the
    # package only provides a script, no binary
    if [[ ! -f /usr/share/bash-completion/bash_completion && ! -f /etc/bash_completion ]]; then
        pkgs+=(bash-completion)
    fi

    # Only on a desktop: notifications need a graphical session to show up,
    # so on a headless VPS or container notify-send would be dead weight.
    # Package name differs per distro.
    if is_desktop && ! command -v notify-send >/dev/null 2>&1; then
        case "$PKG_MGR" in
            apt)    pkgs+=(libnotify-bin) ;;
            zypper) pkgs+=(libnotify-tools) ;;
            *)      pkgs+=(libnotify) ;;
        esac
    fi

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        echo "found: shell tools (less, bash-completion$(command -v notify-send >/dev/null 2>&1 && echo ", notify-send"))"
        return 0
    fi

    echo "installing shell tools: ${pkgs[*]}"
    pkg_install "${pkgs[@]}" || echo "warning: failed to install ${pkgs[*]} — install manually" >&2
}

# Make sure $LOCALE (e.g. en_US.UTF-8) exists on this system, generating or
# installing it if missing. .bash_profile/.zshenv fall back to C.UTF-8 when
# en_US.UTF-8 is missing, so without this you'd get working-but-plain
# C.UTF-8 (ISO dates, byte-order sorting) instead of US English formats.
# Never fails the script: warns and returns on any problem.
ensure_locale() {
    # e.g. en_US.UTF-8 -> lang=en_US
    local lang="${LOCALE%%.*}"

    # macOS ships every locale; Alpine/musl has no `locale` command and
    # accepts any locale name, so there's nothing to install on either
    if [[ "$SYSTEM" == macos-* ]] || ! command -v locale >/dev/null 2>&1; then
        return 0
    fi

    # `locale -a` spells it en_US.utf8 on Linux — hence -i and optional dash
    if locale -a 2>/dev/null | grep -iE "^${lang}\.utf-?8$" >/dev/null; then
        echo "found: locale $LOCALE"
        return 0
    fi

    echo "locale $LOCALE not found, installing..."
    case "$PKG_MGR" in
        apt|pacman)
            # Debian, Ubuntu and Arch build locales from source data with
            # locale-gen. /etc/locale.gen lists every locale commented out;
            # uncommenting ours makes it survive later `locale-gen` runs
            # (e.g. on glibc upgrades). Ubuntu also accepts the name as an
            # argument; Debian and Arch ignore it and read the file.
            if [[ "$PKG_MGR" == "apt" ]]; then
                pkg_install locales || { echo "warning: failed to install locales package" >&2; return 0; }
            fi
            if [[ -f /etc/locale.gen ]]; then
                as_root sed -i "s/^# *\(${LOCALE} UTF-8\)/\1/" /etc/locale.gen
            fi
            as_root locale-gen "$LOCALE" || { echo "warning: locale-gen failed" >&2; return 0; }
            ;;
        dnf|yum)
            # Fedora/RHEL ship locales as per-language packs, e.g. en_US -> glibc-langpack-en
            pkg_install "glibc-langpack-${lang%%_*}" || { echo "warning: failed to install glibc-langpack-${lang%%_*}" >&2; return 0; }
            ;;
        zypper)
            # openSUSE bundles all locales in one package
            pkg_install glibc-locale || { echo "warning: failed to install glibc-locale" >&2; return 0; }
            ;;
        *)
            echo "warning: don't know how to install locales with '${PKG_MGR:-no package manager}' — shells will fall back to C.UTF-8" >&2
            return 0
            ;;
    esac

    if locale -a 2>/dev/null | grep -iE "^${lang}\.utf-?8$" >/dev/null; then
        echo "installed: locale $LOCALE"
    else
        echo "warning: locale $LOCALE still missing — shells will fall back to C.UTF-8" >&2
    fi
}

# Copy repo-relative files to the same path under $HOME, backing up each.
# Shared by the shell installers, which all install a flat list of dotfiles.
install_home_files() {
    for f in "$@"; do
        local src; src="$(fetch_source "$f")"
        local dest="$HOME/$f"

        if [[ ! -f "$src" ]]; then
            echo "error: $src not found" >&2
            continue
        fi

        # Nested paths (e.g. .config/kitty/themes/…) need their folder first;
        # without this, cp fails on a fresh machine where it doesn't exist yet
        mkdir -p "$(dirname "$dest")"
        backup_if_exists "$dest"
        cp "$src" "$dest"
        echo "installed: $dest"
    done
}

# Files sourced by both .zshrc and .bash_profile (shell-specific bits are
# guarded by $ZSH_VERSION / $BASH_VERSION inside the files).
# Installed once here rather than in install_zsh and install_bash — otherwise
# the second installer would back up the copy the first one just made.
install_shell_common() {
    install_home_files .aliases .functions
}

# Configs only — the zsh binary is installed by ensure_zsh when zsh is
# the chosen login shell. Configs are installed regardless, so switching
# shells later just works.
install_zsh() {
    install_home_files .zshrc .zshenv .zprofile
}

install_bash() {
    # No ensure_bash: bash is present on every supported system (it runs
    # this script). macOS ships bash 3.2, which is old but enough here.
    # .bashrc only loads .bash_profile, so non-login shells (new terminal
    # tabs, docker exec) get the same setup as login shells
    install_home_files .bash_profile .bashrc .inputrc
}

# Everything runs from main, called on the very last line. With
# `curl … | bash`, bash runs the script while it's still downloading.
# Wrapped like this, nothing runs until the whole file has arrived — a
# cut-off download can't run half an install, and no command (apt, chsh…)
# can swallow the rest of the script by reading stdin.
main() {
    detect_system
    ask_questions
    confirm_plan

    install_nano
    install_tmux
    ensure_nerd_font
    install_kitty
    install_nvim
    install_starship
    ensure_shell_tools
    ensure_locale
    write_locale_conf
    # zsh binary only when it's the chosen login shell; its configs are
    # installed either way (install_zsh)
    if [[ "$SHELL_CHOICE" == "zsh" ]]; then
        ensure_zsh
    fi
    install_shell_common
    install_zsh
    install_bash
    set_login_shell
}

main "$@"
