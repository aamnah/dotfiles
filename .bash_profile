PS1="\w > "

take () {
	mkdir $1
	cd $1
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

alias ~='cd ~'
alias desk='cd ~/Desktop'
alias sandbox='cd ~/Sandbox'
alias down='cd ~/Downloads'
alias temp='cd ~/Temp'

alias agi='sudo apt-get install'  
alias update='sudo apt-get update'
