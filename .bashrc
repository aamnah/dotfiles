#!/bin/bash
#-----------------------------------------------------------------------
#          File: ~/.bashrc
#   Description: Loads ~/.bash_profile for non-login interactive shells
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.1.0
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2026-10-13
#       Lastmod: 2026-10-13
#-----------------------------------------------------------------------
#
# bash reads ~/.bash_profile only for login shells. New terminal tabs on
# Linux and `docker exec … bash` are non-login shells and read ~/.bashrc
# instead — without this file they'd get no aliases, functions or prompt.
# All real config lives in ~/.bash_profile; this just points to it.
#
# No double-loading: login shells read ~/.bash_profile and skip this file
# (as long as ~/.bash_profile doesn't source ~/.bashrc).

# Stop here for non-interactive shells. bash also reads ~/.bashrc for
# commands run over SSH (scp, rsync, `ssh host cmd`), and any output from
# the profile would corrupt those transfers.
[[ $- != *i* ]] && return

[ -f "$HOME/.bash_profile" ] && . "$HOME/.bash_profile"
