# Begin ~/.bash_profile
# by Aamnah Akram <hello@aamnah.com>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  
# System wide environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.


PS1="\w > "

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Setup a red prompt for root and a green one for normal users.
NORMAL="\[\e[0m\]"
RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$NORMAL\w $RED\$ $NORMAL"
else
  PS1="$NORMAL\w $GREEN\$ $NORMAL"
fi


# create a dir and cd to it by taking an argument
take () {
	mkdir $1
	cd $1
}
