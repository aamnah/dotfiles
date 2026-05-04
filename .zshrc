#!/usr/bin/env zsh
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.2.0
#          Date: 2026-04-24
#       Lastmod: 2026-05-04
#   Description: zsh interactive config — prompt, completion, aliases, functions
# Compatibility: Debian, Ubuntu, Armbian, macOS
#-----------------------------------------------------------------------
#
# Sourced for INTERACTIVE shells (every new terminal tab, login or otherwise).
# Use for: aliases, functions, prompt, completion, keybindings — anything used at the prompt.
# PATH and env vars belong in ~/.zshenv (sourced for every zsh invocation).
# bash equivalent: ~/.bashrc
#

# Shell options (defaults that OMZ used to set)
setopt AUTO_CD              # type a directory name (incl. "..") to cd into it
setopt AUTO_PUSHD           # every cd pushes the previous dir on the stack — popd to go back
setopt PUSHD_IGNORE_DUPS    # don't stack duplicate dirs
setopt EXTENDED_HISTORY     # write timestamp + duration with each history entry
setopt SHARE_HISTORY        # share command history across all running shells
setopt HIST_IGNORE_DUPS     # don't record a line if it matches the previous one
setopt HIST_IGNORE_SPACE    # don't record a line that starts with a space

# Tab completion (OMZ used to init this for you)
autoload -Uz compinit && compinit

# Starship prompt (cross-shell, configured via ~/.config/starship.toml)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# tmuxp manages its own session titles
export DISABLE_AUTO_TITLE='true'

# Personal aliases and functions
# get machine-specific stuff from *.local files
for file in $HOME/.{aliases,aliases.local,functions,functions.local,zshrc.local}; do
  [[ -f "$file" ]] && source "$file"
done
unset file

#-----------------------------------------------------------------------
