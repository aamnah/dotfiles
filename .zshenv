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

# PATHS
# -----------------------------------------------------------------------
# Neovim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# JetBrains IDEs
export PATH="$PATH:/opt/clion/bin"
export PATH="$PATH:/opt/rider/bin"

# Go
export PATH="$PATH:/usr/local/go/bin"

# Elixir
export PATH=$PATH:$HOME/.elixir-install/installs/otp/27.1.2/bin
export PATH=$PATH:$HOME/.elixir-install/installs/elixir/1.18.2-otp-27/bin

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "/home/amna/.deno/env"

# Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Flutter
export PATH="$PATH:$HOME/flutter/bin"

# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# Hugging Face (HF)
# https://huggingface.co/docs/huggingface_hub/package_reference/environment_variables
export HF_HOME="/mnt/amna/Media/LLM Models"

# API keys for AI/coding tools
# Real values live in ~/.zsh_secrets (gitignored) and are sourced below.
# Pi Coding Agent: ZAI_API_KEY="$ZAI_API_KEY" pi --provider zai --model glm-4.6
export ZAI_API_KEY=""        # GLM Models
export OPENCODE_API_KEY=""   # OpenCode Zen
export OPENROUTER_API_KEY=""
export GEMINI_API_KEY=""

# Source machine-local secrets (not tracked in dotfiles)
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"