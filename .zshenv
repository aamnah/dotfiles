#!/usr/bin/env zsh
#-----------------------------------------------------------------------
#          File: ~/.zshenv
#   Description: zsh env — PATH and env vars sourced by every zsh invocation
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.1.1
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2026-04-24
#       Lastmod: 2026-05-05
#-----------------------------------------------------------------------
# Sourced for EVERY zsh invocation: interactive, login, scripts, cron, GUI launches.
# .zshenv is sourced every time zsh starts, no matter the mode:
#     interactive (your terminal)
#     non-interactive (scripts, SSH commands, etc.)
# So anything you put there will be available to:
#     all zsh shells
#     any process launched from those shells
# Put PATH and env vars here so non-interactive contexts (cron, GUI apps, scripts) inherit them

# OS detection — set once, used by aliases that differ between Linux (GNU) and macOS (BSD)
# since .zshenv is loaded before .zshrc and others, 
# they will inherit IS_MACOS and IS_LINUX if it is set
case "$(uname -s)" in
  Darwin)  IS_MACOS=1 ;;
  Linux)   IS_LINUX=1 ;;
esac
export IS_MACOS IS_LINUX

# Locale settings needed for Fastlane/Cocoapods
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Dotnet
# https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=true   # true means off

# Source machine-local secrets (not tracked in dotfiles)
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# Machine-local PATH and env. Lives here (not .zshrc) so non-interactive
# zsh invocations — cron, scripts, ssh host 'cmd', GUI apps — inherit PATH.
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

#-----------------------------------------------------------------------

# Homebrew (cross-platform)
# Load Homebrew from the same dotfiles on different operating systems.
# Sets PATH/MANPATH/INFOPATH for brew-installed packages.
# Cache the shellenv output — skips the ~20–40ms `brew shellenv` fork on every
# shell startup. Cache is rebuilt when the brew binary is newer than the cache.
for brewbin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brewbin" ]]; then
        _brew_cache="$HOME/.cache/brew_shellenv"
        if [[ ! -s "$_brew_cache" ]] || [[ "$brewbin" -nt "$_brew_cache" ]]; then
            mkdir -p "$HOME/.cache" && "$brewbin" shellenv > "$_brew_cache"
        fi
        source "$_brew_cache"
        unset _brew_cache
        break
    fi
done

# NVM — env only. Lazy-load stubs live in .zshrc (interactive only).
# Defining node()/npm()/etc. here would shadow the real binary in scripts and
# cron, making every non-interactive `node script.js` pay the nvm.sh source cost.
export NVM_DIR="$HOME/.nvm"
# Put default node's bin on PATH so scripts, cron, and quick `node -v` find a
# real binary without sourcing nvm.sh. Resolve the alias chain
# (default → lts/iron → 20.18.0) so PATH points at a real version dir.
if [[ -s "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(<"$NVM_DIR/alias/default")"
  while [[ -s "$NVM_DIR/alias/$_nvm_default" ]]; do
    _nvm_default="$(<"$NVM_DIR/alias/$_nvm_default")"
  done
  [[ -d "$NVM_DIR/versions/node/v$_nvm_default" ]] && \
    export PATH="$NVM_DIR/versions/node/v$_nvm_default/bin:$PATH"
  unset _nvm_default
fi

#-----------------------------------------------------------------------

# .zshenv is the first zsh startup file, and the only one sourced for every zsh invocation, no matter the mode.

#   When it runs
#------------------------------------
#   Zsh has five startup files, sourced in this order based on shell type:

#   ┌───────────┬─────────────┬────────────┬──────────────────┐
#   │   File    │ Every shell │ Login only │ Interactive only │
#   ├───────────┼─────────────┼────────────┼──────────────────┤
#   │ .zshenv   │     ✅      │            │                  │
#   ├───────────┼─────────────┼────────────┼──────────────────┤
#   │ .zprofile │             │     ✅     │                  │
#   ├───────────┼─────────────┼────────────┼──────────────────┤
#   │ .zshrc    │             │            │        ✅        │
#   ├───────────┼─────────────┼────────────┼──────────────────┤
#   │ .zlogin   │             │     ✅     │                  │
#   ├───────────┼─────────────┼────────────┼──────────────────┤
#   │ .zlogout  │             │ ✅ (exit)  │                  │
#   └───────────┴─────────────┴────────────┴──────────────────┘

#   "Every shell" means .zshenv runs for:
#   - Interactive terminals (Terminal.app, iTerm, tmux pane)
#   - Login shells (ssh user@host, console login)
#   - Non-interactive scripts (zsh script.zsh, #!/usr/bin/env zsh)
#   - Single commands (zsh -c 'foo', including ssh host 'foo')
#   - GUI apps that spawn a zsh subprocess (cron, launchd, editors running shell commands)

#   The other files are conditional: .zprofile/.zlogin only run for login shells, .zshrc only for interactive shells.

# What belongs in it
#------------------------------------
# Anything a non-interactive shell needs to function correctly. The classic two:

# 1. PATH and other env vars. A cron job, a #!/usr/bin/env zsh script, or ssh host 'mycmd' never sources .zshrc. If mycmd lives in /opt/homebrew/bin and that path is added in .zshrc, the cron job breaks. Putting it in .zshenv ensures every zsh invocation sees it.
# 2. Locale / behavior env vars — LANG, LC_ALL, EDITOR, PAGER, tool-specific things like
# DOTNET_CLI_TELEMETRY_OPTOUT, secrets sourced from a separate file.

# What does NOT belong
#------------------------------------
# - Aliases, functions, completion, key bindings, prompt — these only matter at the prompt, so they belong in .zshrc. Putting them in .zshenv wastes time on every script invocation.
# - Anything that prints output or reads stdin — would corrupt scripts and SSH command output.
# - Anything slow (e.g., nvm.sh, pyenv init) — runs on every script execution and slows everything down. Lazy-load these in .zshrc instead.