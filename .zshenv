#!/usr/bin/env zsh
#-----------------------------------------------------------------------
#          File: ~/.zshenv
#   Description: zsh env — PATH and env vars sourced by every zsh invocation
# Compatibility: Debian, Ubuntu, Armbian, macOS
#       Version: 0.1.0
#        Author: Aamnah
#          Link: https://aamnah.com
#          Date: 2026-04-24
#       Lastmod: 2026-05-04
#-----------------------------------------------------------------------
# Sourced for EVERY zsh invocation: interactive, login, scripts, cron, GUI launches.
# .zshenv is sourced every time zsh starts, no matter the mode:
#     interactive (your terminal)
#     non-interactive (scripts, SSH commands, etc.)
# So anything you put there will be available to:
#     all zsh shells
#     any process launched from those shells
# Put PATH and env vars here so non-interactive contexts (cron, GUI apps, scripts) inherit them

# Source machine-local secrets (not tracked in dotfiles)
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# Locale settings needed for Fastlane/Cocoapods
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Dotnet
# https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=true   # true means off


