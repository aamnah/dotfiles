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

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    local src="$REPO_DIR/.nanorc"
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
    local src="$REPO_DIR/.tmux.conf"
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

detect_system
install_nano
install_tmux
