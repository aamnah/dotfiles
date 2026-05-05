#!/usr/bin/env zsh
#-----------------------------------------------------------------------
#          File: ~/.zshrc
#   Description: zsh interactive config — prompt, completion, aliases, functions
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.2.1
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2026-04-24
#       Lastmod: 2026-05-05
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
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate when a newer match is added (stronger than HIST_IGNORE_DUPS)
setopt HIST_IGNORE_SPACE    # don't record a line that starts with a space
setopt HIST_REDUCE_BLANKS   # collapse runs of whitespace before storing

# History file/size — zsh's default SAVEHIST is 0 (nothing persists). Set sane caps.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Tab completion — refresh the dump cache once a day; otherwise skip the
# security audit (saves ~50–100ms). Glob qualifier `mh+24` matches files
# older than 24 hours; the `N` makes a missing dump silently skip too.
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

# Personal aliases and functions
# get machine-specific stuff from *.local files
for file in $HOME/.{aliases,aliases.local,zsh_aliases,zsh_aliases.local,functions,functions.local,zsh_functions,zsh_functions.local,zshrc.local}; do
  [[ -f "$file" ]] && source "$file"
done
unset file

# tmuxp manages its own session titles
export DISABLE_AUTO_TITLE='true'

# Starship prompt (cross-shell, configured via ~/.config/starship.toml)
# NOTE: if starship is installed with homebrew, then it needs to eval 
# after brew has already been referenced in shell
# curl -sS https://starship.rs/install.sh | sh
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

#-----------------------------------------------------------------------

