#!/usr/bin/env zsh
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.1.0
#          Date: 2026-04-24
#       Lastmod: 2026-04-24
#   Description: zsh env — PATH and env vars sourced by every zsh invocation
# Compatibility: Debian, Ubuntu, Armbian, macOS
#-----------------------------------------------------------------------
#
# Sourced for EVERY zsh invocation: interactive, login, scripts, cron, GUI launches.
# Put PATH and env vars here so non-interactive contexts (cron, GUI apps, scripts) inherit them.
# bash equivalent: none — bash has no file that runs for every invocation.
#
# Source machine-local secrets (not tracked in dotfiles)
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# Locale settings needed for Fastlane/Cocoapods
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Dotnet
# https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=true   # true means off