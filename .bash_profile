# Begin ~/.bash_profile
# by Aamnah Akram <hello@aamnah.com>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.
# System wide environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases, ~/.functions and ~/.colors
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions,colors}; do
	[ -r "$file" ] && source "$file"
done
unset file

# setup local path
export PATH=/usr/local/bin:$PATH


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


PS1="\w > "

# COLORS
color_blue="\033[94m" #blue
color_cyan="\033[0;36m" #cyan
color_green='\033[92m' #green
color_magenta="\033[95m" #magenta
color_red='\033[91m' #red
color_yellow='\033[93m' #yellow
color_off='\033[0m'

# Setup a red prompt for root and a green one for normal users.
NORMAL="\[\e[0m\]"
RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$NORMAL\w $RED\$ $NORMAL"
else
  PS1="$NORMAL\w $GREEN\$ $NORMAL"
fi


# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# COLOR CODING
# Enable color coding for tree and ls and define colors
export CLICOLOR=1
export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"
# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Run GRC with every new shell
source "`brew --prefix grc`/etc/grc.bashrc"

# Set the WORKON_HOME variable for virtualenvwrapper
export WORKON_HOME="~/.virtualenvs"

# Source the virtualenvwrapper shell script to be able to run commands
source /usr/local/bin/virtualenvwrapper.sh
