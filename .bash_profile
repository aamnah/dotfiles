# ~/.bash_profile

# Author: Aamnah <hello@aamnah.com> @AamnahAkram
# Link: https://aamnah.com
# Version: 0.0.3
# lastmod: 2018-12-20

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.
# System wide environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

# PROMPT
# non-printable sequences need to be wrapped with \[...\] in order to let Bash calculate the correct length of the prompt.
# more: https://unix.stackexchange.com/questions/28827/why-is-my-bash-prompt-getting-bugged-when-i-browse-the-history
RED='\[\e[91m\]'
GREEN='\[\e[92m\]'
NORMAL='\[\e[0m\]'

PS1="\n\w ${GREEN}\$ ${NORMAL}\n"

# SOURCE OTHER FILES
# source other bash conf files like ~/.aliases etc
for file in ~/.{aliases, bash_aliases, colors, bash_colors }; do
  [ -r "$file" ] && source "$file"
done
unset file

# SHELL OPTIONAL BEHAVIOUR
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect minor typos in path names when using `cd`
shopt -s cdspell;

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# COLOR CODING
# Enable color coding for tree and ls and define colors
export CLICOLOR=1
#export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'
