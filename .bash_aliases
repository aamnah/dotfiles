# ~/.bash_aliases

# Author: Aamnah <hello@aamnah.com> @AamnahAkram
# Link: https://aamnah.com
# Version: 0.0.3
# lastmod: 2019-11-25

# take a look at http://alias.sh/
# for some really cool aliases
# http://www.commandlinefu.com/commands/

## DIRs
#############
alias ..='cd ..'
alias desk='cd ~/Desktop'
alias dl='cd ~/Downloads'

# COMMANDS
#############
alias ls='ls -hF'
alias ll='ls -alhF --color' # -a for all, -l for detailed, -h for human readable, F for trailing /, --color for color coding
alias lsd='ls -Gal | grep ^d' # Only list directories, including hidden ones
alias la='ls -A'
alias l='ls -aFx --color' # -x for line based listing instead of columns

# Always list the tree command in color coding
alias tree='tree -C'

# grep --color=auto displays colored output unless output piped to a different command
# grep --color=always always colors output, even adding control sequences to other piped commands
# more: https://linuxcommando.blogspot.com/2007/10/grep-with-color-output.html
alias grep='grep --color=always' 
alias egrep='egrep --color=always' 
alias fgrep='fgrep --color=always' 

# youtube-dl
alias ydl='youtube-dl'


# MISC.
#############
## IP addresses
alias myip='curl ifconfig.me'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

## Empty the Trash on all mounted volumes and the main HDD
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash"

## Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

## Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

## Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

## Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# SUDO
alias dang='sudo $(history -p \!\!)'


## DISK USAGE
#############
# List top ten largest files/directories in current directory
# alias ducks='du -cks *|sort -rn|head -11'
# du -cks : -c for grand total , -k for 1-Kbyte blocks, -s for displaying entries for each file
# sort -rn : -r for reverse order, -n for numeric sort
# head -11 : display first 11 lines
alias ducks='du -chs * | sort -rh | head -11' # same as above but human-readable

# Find the biggest in a folder
alias ds='du -ks *|sort -n'


## MEMORY
#############
# What's gobbling the memory?
alias wotgobblemem='ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6 | tail -15'


## DNS
#############
# Flush DNS cache
alias flushdns='sudo dscacheutil -flushcache'


## SECURITY
#############
# Show active network listeners
alias netlisteners='lsof -i -P | grep LISTEN'

# spy() and sniff() have been added to .functions
