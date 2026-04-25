#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.1.0
#          Date: 2024-04-24
#       Lastmod: 2024-04-25
#   Description: Catppuccin Tmux Theme
#         Theme: https://github.com/catppuccin/tmux
# Compatibility: Debian, Ubuntu, Armbian, macOS
#          File: ~/.tmux/catppuccin.tmux
#-----------------------------------------------------------------------

source-file ~/.tmux/reset.tmux

# Install Catppuccin:
# mkdir -p ~/.config/tmux/plugins/catppuccin
# git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# Catppuccin options
# ---------------------------------------------------------------
set -g @catppuccin_flavour 'mocha' # latte, frappe, macchiato or mocha
set -g @catppuccin_window_status_style "rounded"

# Load Catppuccin. This defines @catppuccin_status_* modules.
run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux

# Status line modules
# ---------------------------------------------------------------
set -g status-right-length 100
set -g status-left-length 100

# Flags on `set -ag` below:
#   -a = append to the existing value (don't overwrite)
#   -g = global (apply to all sessions, not just the current one)
# Do NOT use -F for the session module: it expands #S immediately and bakes
# the current session name into the global status-left for every session.

# LEFT
set -g status-left "" # reset first, the rest will append to it with -a
set -ag status-left "#{E:@catppuccin_status_session}"

# RIGHT
set -g status-right "" # reset first, the rest will append to it with -a
set -agF status-right "#{E:@catppuccin_status_cpu}"
set -agF status-right "#{E:@catppuccin_status_ram}"
set -agF status-right "#{E:@catppuccin_status_weather}"
set -agF status-right "#{E:@catppuccin_status_host}"
set -agF status-right "#{E:@catppuccin_status_date_time}"
