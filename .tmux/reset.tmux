#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.1.0
#          Date: 2024-04-25
#       Lastmod: 2024-04-25
#   Description: Reset theme-controlled tmux options before loading a theme
# Compatibility: Debian, Ubuntu, Armbian, macOS
#          File: ~/.tmux/reset.tmux
#-----------------------------------------------------------------------

# Reset any stale styles from previously-tested themes before a new theme loads.
# e.g. a `source-file` reload keeps old bg colors set on the running
# server, which bleeds through behind Catppuccin's rounded modules.

# Tmux options persist in the running server; resetting prevents bleed-through
# when switching between Catppuccin, Lasik, or future themes.

# Status
set -g status on
set -g status-left ""
set -g status-right ""
set -g status-left-length 100
set -g status-right-length 100
set -g status-style default
set -g status-left-style default
set -g status-right-style default
set -g status-justify left

# Windows in status bar
set -g window-status-format "#I:#W#F"
set -g window-status-current-format "#I:#W#F"
set -g window-status-separator " "
set -g window-status-style default
set -g window-status-current-style default
set -g window-status-activity-style default
set -g window-status-bell-style default

# Panes/windows
set -g pane-border-style default
set -g pane-active-border-style default
set -g window-style default
set -g window-active-style default

# Messages / modes
set -g message-style default
set -g mode-style default
