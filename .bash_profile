# ~/.bash_profile

# Author: Aamnah <hello@aamnah.com> @AamnahAkram
# Link: https://aamnah.com
# Version: 0.0.3
# lastmod: 2019-11-06

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.
# System wide environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

# PROMPT
# non-printable sequences need to be wrapped with \[...\] in order to let Bash calculate the correct length of the prompt.
# more: https://unix.stackexchange.com/questions/28827/why-is-my-bash-prompt-getting-bugged-when-i-browse-the-history
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

RED='\[\e[91m\]'
GREEN='\[\e[92m\]'
BLUE='\[\e[94m\]'
YELLOW='\[\e[93m\]'
NORMAL='\[\e[0m\]'

#PS1="\n${BLUE}\w${YELLOW}\$(parse_git_branch) ${GREEN}\$ ${NORMAL}\n"
if [[ $EUID -ne 0 ]]; then
	# user is not root, show green $
	PS1="\n${BLUE}\w${YELLOW}\$(parse_git_branch) ${GREEN}\$ ${NORMAL}\n"
else
	# user is root, show red #
	PS1="\n${BLUE}\w${YELLOW}\$(parse_git_branch) ${RED}\$ ${NORMAL}\n"
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
for file in ~/.{aliases, bash_aliases, colors, bash_colors }; do
  [ -r "$file" ] && source "$file"
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
