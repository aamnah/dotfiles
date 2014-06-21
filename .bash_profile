PS1="\w > "

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Aliases
alias ~='cd ~'
alias desk='cd ~/Desktop'
alias sandbox='cd ~/Sandbox'
alias down='cd ~/Downloads'
alias temp='cd ~/Temp'

alias agi='sudo apt-get install'  
alias update='sudo apt-get update'

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$NORMAL\w $RED\$ $NORMAL"
else
  PS1="$NORMAL\w $GREEN\$ $NORMAL"
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

# create a dir and cd to it by taking an argument
take () {
	mkdir $1
	cd $1
}
