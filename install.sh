#!/usr/bin/env bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.1.0
#          Date: 2026-04-24
#       Lastmod: 2026-04-24
#   Description: Dotfile installer with OS/arch detection (Linux, macOS Intel/ARM)
# Compatibility: Debian, Ubuntu, Armbian, macOS
#-----------------------------------------------------------------------

set -euo pipefail

REPO_SLUG="aamnah/dotfiles"
REPO_BRANCH="master"
RAW_BASE="https://raw.githubusercontent.com/$REPO_SLUG/$REPO_BRANCH"

MODE="local"
for arg in "$@"; do
    case "$arg" in
        --remote) MODE="remote" ;;
        -h|--help)
            cat <<EOF
Usage: install.sh [--remote]

  (default)  Copy configs from this checkout to \$HOME.
  --remote   Fetch configs from $RAW_BASE and install to \$HOME (no clone needed).
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
    echo "detected: $SYSTEM"
}

backup_if_exists() {
    local dest="$1"
    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
        echo "backing up $dest -> $backup"
        mv "$dest" "$backup"
    fi
}

install_nano() {
    local src; src="$(fetch_source ".nanorc")"
    local dest="$HOME/.nanorc"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if [[ "$SYSTEM" == macos-* ]]; then
        if ! command -v nano >/dev/null 2>&1 || ! nano --version 2>/dev/null | grep -q 'GNU nano'; then
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

install_tmux() {
    local src; src="$(fetch_source ".tmux.conf")"
    local dest="$HOME/.tmux.conf"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if ! command -v tmux >/dev/null 2>&1; then
        if [[ "$SYSTEM" == macos-* ]]; then
            echo "warning: tmux not found. Install with: brew install tmux" >&2
        else
            echo "warning: tmux not found. Install with your package manager (e.g. apt install tmux)" >&2
        fi
    fi

    backup_if_exists "$dest"
    cp "$src" "$dest"
    echo "installed: $dest"
}

install_kitty() {
    local src; src="$(fetch_source ".config/kitty/kitty.conf")"
    local dest="$HOME/.config/kitty/kitty.conf"

    if [[ ! -f "$src" ]]; then
        echo "error: $src not found" >&2
        return 1
    fi

    if ! command -v kitty >/dev/null 2>&1; then
        if [[ "$SYSTEM" == macos-* ]]; then
            echo "warning: kitty not found. Install with: brew install --cask kitty" >&2
        else
            echo "warning: kitty not found. Install from https://sw.kovidgoyal.net/kitty/binary/ or your package manager" >&2
        fi
    fi

    mkdir -p "$(dirname "$dest")"
    backup_if_exists "$dest"
    cp "$src" "$dest"
    echo "installed: $dest"
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

detect_system
install_nano
install_tmux
install_kitty
install_nvim
install_starship
