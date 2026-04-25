#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.4
#          Date: 2020-07-15
#       Lastmod: 2026-04-24
#   Description: Bash aliases — dirs, listings, grep, IPs, trash, DNS (cross-platform: Linux + macOS)
# Compatibility: Debian, Ubuntu, Armbian, macOS
#-----------------------------------------------------------------------

# ~/.bash_aliases
# More ideas: http://alias.sh/  and  http://www.commandlinefu.com/commands/

# OS detection — set once, used to gate platform-specific aliases below
case "$(uname -s)" in
    Darwin) IS_MACOS=1 ;;
    Linux)  IS_LINUX=1 ;;
esac

## DIRs (HOME-relative — work on any box)
# ---------------------------------------------------------------
alias desk='cd ~/Desktop'
alias dl='cd ~/Downloads'

# COMMANDS
# ---------------------------------------------------------------
# ls colorflag differs: GNU uses --color=, BSD (macOS) uses -G
if [[ -n "$IS_MACOS" ]]; then
    alias ls='ls -hFG'
    alias ll='ls -alhFG'
    alias l='ls -aFxG'
else
    alias ls='ls -hF --color=always'
    alias ll='ls -alhF --color=always'
    alias l='ls -aFx --color=always'
fi

# Only list directories (including hidden, excluding . and ..)
# Cross-platform: works without GNU-specific flags
alias lsd='ls -dl */ .[^.]*/ 2>/dev/null'

alias la='ls -A'

# Always color-code the tree command
alias tree='tree -C'

# grep --color=auto displays colored output unless output piped to a different command
# grep --color=always always colors output, even adding control sequences to other piped commands
# more: https://linuxcommando.blogspot.com/2007/10/grep-with-color-output.html
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias fgrep='fgrep --color=always'

# Tools (universal — work on any box where the tool is installed)
alias c="claude"
alias kkk="tmux kill-session"
alias peaclock="peaclock --config-dir ~/.config/peaclock"

# MISC.
# ---------------------------------------------------------------
## IP addresses
alias myip='curl ifconfig.me'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

# localip differs: macOS has `ipconfig getifaddr`; Linux uses `hostname -I`
if [[ -n "$IS_MACOS" ]]; then
    alias localip='ipconfig getifaddr en0'
else
    alias localip="hostname -I | awk '{print \$1}'"
fi

## Empty the Trash
# macOS: trash lives in /Volumes/*/.Trashes (per-mount) and ~/.Trash
# Linux: XDG trash spec is ~/.local/share/Trash/{files,info}
if [[ -n "$IS_MACOS" ]]; then
    alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash'
else
    alias emptytrash='rm -rfv ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null'
fi

## Recursively delete `.DS_Store` files (macOS leftovers, harmless on Linux)
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

## Kill Chrome renderer tabs to free up memory (preserves extensions)
# Cross-platform: matches both "Chrome Helper --type=renderer" (macOS)
# and "chrome --type=renderer" (Linux). Uses [Cc] bracket trick so grep
# doesn't match itself in the ps output.
alias chromekill="ps ux | grep -E '[Cc]hrome( Helper)? --type=renderer' | grep -v extension-process | awk '{print \$2}' | xargs kill 2>/dev/null"

## Lock the screen (when going AFK)
if [[ -n "$IS_MACOS" ]]; then
    alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
else
    # Try systemd's loginctl first, then xdg-screensaver. Keyboard shortcut on most desktops is Super+L.
    alias afk='loginctl lock-session 2>/dev/null || xdg-screensaver lock'
fi

## Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# SUDO
alias dang='sudo $(history -p \!\!)'


## DISK USAGE
# ---------------------------------------------------------------
# List top ten largest files/directories in current directory
# alias ducks='du -cks *|sort -rn|head -11'
# du -cks : -c for grand total , -k for 1-Kbyte blocks, -s for displaying entries for each file
# sort -rn : -r for reverse order, -n for numeric sort
# head -11 : display first 11 lines
# NOTE: `sort -h` (human-numeric) is GNU-only on older macOS. Modern macOS (Mojave+)
# supports it. On older macOS, `brew install coreutils` and use `gsort -rh` instead.
alias ducks='du -chs * | sort -rh | head -11' # human-readable

# Find the biggest in a folder
alias ds='du -ks * | sort -n'


## MEMORY
# ---------------------------------------------------------------
# What's gobbling the memory? (cross-platform: BSD and GNU ps both accept these column names)
alias wotgobblemem='ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6 | tail -15'


## DNS
# ---------------------------------------------------------------
# Flush DNS cache
if [[ -n "$IS_MACOS" ]]; then
    # On modern macOS, flushing requires both dscacheutil and an mDNSResponder reload
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
else
    # systemd-resolved is the modern default; resolvectl is the current command, systemd-resolve is the older one
    alias flushdns='sudo resolvectl flush-caches 2>/dev/null || sudo systemd-resolve --flush-caches 2>/dev/null || echo "no known resolver to flush — check your distro"'
fi


## SECURITY
# ---------------------------------------------------------------
# Show active network listeners (cross-platform: lsof works on both)
alias netlisteners='lsof -i -P | grep LISTEN'

# spy() and sniff() have been added to .bash_functions
