#!/bin/bash
#-----------------------------------------------------------------------
#          File: ~/.bash_profile
#   Description: bash startup — prompt, history, shopt, color, paths, aliases
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.5.1
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2020-07-15
#       Lastmod: 2026-10-13
#-----------------------------------------------------------------------
#
# Sourced for LOGIN shells. Doubles as ~/.bashrc (interactive) here —
# many personal setups consolidate both into one file.
# bash splits startup into ~/.bash_profile (login) and ~/.bashrc (interactive);
# unlike zsh, bash has no equivalent of ~/.zshenv that runs for every invocation.
# zsh equivalents: ~/.zprofile (login) + ~/.zshrc (interactive)
# System-wide equivalents: /etc/profile (login), /etc/bashrc (interactive)
#

# PROMPT
# Prefer starship (cross-shell, configured via ~/.config/starship.toml).
# Fallback: manual git-aware PS1 — used on minimal boxes (VPS/Docker) where starship isn't installed.
# Non-printable sequences in PS1 must be wrapped with \[...\] so Bash measures prompt width correctly.
# more: https://unix.stackexchange.com/questions/28827/why-is-my-bash-prompt-getting-bugged-when-i-browse-the-history
if command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
else
	parse_git_branch() {
	  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
	}

	RED='\[\e[91m\]'
	GREEN='\[\e[92m\]'
	BLUE='\[\e[94m\]'
	YELLOW='\[\e[93m\]'
	NORMAL='\[\e[0m\]'

	if [[ $EUID -ne 0 ]]; then
		# user is not root, show green $
		PS1="\n${BLUE}\w${YELLOW}\$(parse_git_branch) ${GREEN}\$ ${NORMAL}\n"
	else
		# user is root, show red #
		PS1="\n${BLUE}\w${YELLOW}\$(parse_git_branch) ${RED}\$ ${NORMAL}\n"
	fi
fi

# BASH HISTORY
# Add Timestamps to Bash histry `history`
export HISTTIMEFORMAT="%c "

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# SHELL OPTIONAL BEHAVIOUR
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect minor typos in path names when using `cd`
shopt -s cdspell;

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Locale: the one picked during install.sh is saved as LANG=… in
# ~/.config/locale.conf; en_US.UTF-8 (US English, UTF-8) if that file
# doesn't exist. Same logic as .zshenv.
_locale="en_US.UTF-8"
if [[ -r "$HOME/.config/locale.conf" ]]; then
  while IFS='=' read -r _key _val; do
    [[ "$_key" == "LANG" && -n "$_val" ]] && _locale="${_val//\"/}"
  done < "$HOME/.config/locale.conf"
fi
# Use it only if this system has it. Minimal servers and Docker images
# often ship only C.UTF-8; forcing a missing locale makes bash print
# "setlocale: cannot change locale" on every start (and perl/python warn
# on every run).
# C.UTF-8 keeps UTF-8 (emoji, accents) with plain-English messages.
# `locale -a` spells it en_US.utf8 on Linux, en_US.UTF-8 on macOS — hence -i.
# No `locale` command (Alpine/musl): musl accepts any name, so keep it.
if ! command -v locale >/dev/null 2>&1 || locale -a 2>/dev/null | grep -qiE "^${_locale%%.*}\.utf-?8$"; then
  export LC_ALL="$_locale"
  export LANG="$_locale"
else
  export LC_ALL="C.UTF-8"
  export LANG="C.UTF-8"
fi
unset _locale _key _val

# COLOR CODING
# Enable color coding for tree and ls and define colors
export CLICOLOR=1
#export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# Ubuntu defaults (from 26.04 LTS /etc/skel/.bashrc) — this file replaces
# that .bashrc, so without these blocks we'd lose them.

# lesspipe lets `less` open non-text files (archives, PDFs, images) by
# showing a readable summary instead of binary garbage.
# SHELL=/bin/sh makes lesspipe print sh-syntax exports.
command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"

# dircolors sets LS_COLORS, the colour scheme GNU ls --color uses.
# Without it ls still colours, but with the built-in scheme only.
# Put a custom scheme in ~/.dircolors (dircolors -p > ~/.dircolors to start).
# Not on macOS — there, CLICOLOR above handles ls colours.
if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi



# Alias and other definitions
# SOURCE OTHER FILES
# source other bash conf files like ~/.aliases etc
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
# NOTE: bash brace expansion is broken by spaces between commas — keep this list tight.
for file in ~/.{aliases,aliases.local,functions,functions.local}; do
  [ -f "$file" ] && source "$file"
done
unset file

# Programmable Tab completion (git branches, apt packages, ssh hosts…) —
# Ubuntu default. Without it, Tab only completes file and command names.
# Skipped in POSIX mode, where bash-completion doesn't work.
# Needs the bash-completion package (apt install bash-completion).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# PATHS
# -----------------------------------------------------------------------

# Personal bin folders — Ubuntu adds these in ~/.profile, but bash stops
# reading ~/.profile once ~/.bash_profile exists. Without this, tools in
# ~/.local/bin (pipx, uv…) go missing in SSH / login shells.
# Guarded so a path is only added once (no duplicates when nested).
for _dir in "$HOME/bin" "$HOME/.local/bin"; do
  if [ -d "$_dir" ] && [[ ":$PATH:" != *":$_dir:"* ]]; then
    PATH="$_dir:$PATH"
  fi
done
unset _dir

# Android SDK — only when it's installed. Without the check, every machine
# gets four PATH entries pointing at folders that don't exist.
if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME=$HOME/Android/Sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# API keys and tokens (not tracked in dotfiles). Same file zsh loads from
# .zshenv: despite the name it's plain `export NAME="value"` lines, which
# both shells understand. Without this, bash sessions have no API keys.
[ -f "$HOME/.zsh_secrets" ] && . "$HOME/.zsh_secrets"

# Machine-specific PATH and environment for THIS computer (bash's counterpart
# of ~/.zshenv.local). Never committed. Tools' installers append lines to
# ~/.bashrc or ~/.profile — move them here so a dotfiles re-install (which
# replaces ~/.bashrc) can't drop them. Loaded last so it can override anything.
[ -f "$HOME/.bash_profile.local" ] && . "$HOME/.bash_profile.local"
