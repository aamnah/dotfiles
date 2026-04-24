#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.5
#          Date: 2020-07-15
#       Lastmod: 2026-04-24
#   Description: bash startup — prompt, history, shopt, color, paths, aliases
# Compatibility: Debian, Ubuntu, Armbian, macOS
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


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
    alias dir='dir --color=always'
    alias vdir='vdir --color=always'

    alias grep='grep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

# Alias and other definitions
# SOURCE OTHER FILES
# source other bash conf files like ~/.aliases etc
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
# NOTE: bash brace expansion is broken by spaces between commas — keep this list tight.
for file in ~/.{bash_aliases,bash_functions}; do
  [ -f "$file" ] && source "$file"
done
unset file

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

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# COLOR CODING
# Enable color coding for tree and ls and define colors
export CLICOLOR=1
#export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# PATHS
# -----------------------------------------------------------------------

# Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
