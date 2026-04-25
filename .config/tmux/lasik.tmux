#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.1.0
#          Date: 2018-08-16
#       Lastmod: 2024-04-25
#   Description: Lasik Tmux Theme (matches Lasik VSCode theme)
#         Theme: https://marketplace.visualstudio.com/items?itemName=AmnaAkram.lasik
# Compatibility: Debian, Ubuntu, Armbian, macOS
#          File: ~/.config/tmux/lasik.tmux
#-----------------------------------------------------------------------

source-file ~/.config/tmux/reset.tmux

# There are examples in `/usr/share/doc/tmux/examples/`

# VARIABLES
# Tmux config files are not shell scripts, even with the shebang above.
# Use `%hidden NAME=value` for local tmux config variables. These are expanded
# by tmux while sourcing this file, so the palette stays easy to update without
# leaking helper variables into normal tmux options.

# COLORS: Lasik VSCode Theme palette
# ---------------------------------------------------------------------
# Background tones (darkest → lightest)
%hidden BG_DARK='#01030a'         # editor bg (near-black navy)
%hidden BG_DARKER='#010102'       # titlebar bg (almost pure black)
%hidden BG_STATUS='#090b10'       # status bar bg (one step up from BG_DARK)
%hidden BORDER='#2b2b2b'          # neutral dark border

# Foreground tones
%hidden FG='#cccccc'              # primary text
%hidden FG_MUTED='#9d9d9d'        # dimmed/inactive text

# Accent colors (from Lasik syntax highlighting)
%hidden LAVENDER='#a8bcfc'        # theme signature — icons, active elements
%hidden BLUE='#4daafc'            # links
%hidden PINK='#e95678'            # variables / tags
%hidden PEACH='#fab795'           # strings
%hidden TEAL='#02bbcc'            # function names
%hidden PURPLE='#d993ff'          # keywords
%hidden RED='#f85149'             # errors

# CUSTOM STYLES
# Set styles here, saves me scrolling down down down.
# FG first, BG second. Be consistent.
# ---------------------------------------------------------------------
%hidden WINDOW_FG="${FG_MUTED}"
%hidden WINDOW_BG="${BG_DARK}"
%hidden WINDOW_ACTIVE_FG="${FG}"
%hidden WINDOW_ACTIVE_BG="${BG_DARK}"

%hidden PANE_BORDER_FG="${BORDER}"
%hidden PANE_BORDER_BG="${BG_DARK}"
%hidden PANE_ACTIVE_BORDER_FG="${LAVENDER}"
%hidden PANE_ACTIVE_BORDER_BG="${BG_DARK}"

%hidden STATUS_FG="${FG}"
%hidden STATUS_BG="${BG_STATUS}"
%hidden STATUS_LEFT_FG="${BG_DARKER}"
%hidden STATUS_LEFT_BG="${PINK}"
%hidden STATUS_RIGHT_FG="${BG_DARKER}"
%hidden STATUS_RIGHT_BG="${LAVENDER}"

%hidden WINDOW_STATUS_FG="${FG_MUTED}"
%hidden WINDOW_STATUS_BG="${BG_STATUS}"
%hidden WINDOW_STATUS_CURRENT_FG="${BG_DARKER}"
%hidden WINDOW_STATUS_CURRENT_BG="${LAVENDER}"

# CUSTOM FORMATS
# ---------------------------------------------------------------------
%hidden WINDOW_STATUS_SEPARATOR="  "
%hidden WINDOW_STATUS_FORMAT=" #I. #W#F "
%hidden WINDOW_STATUS_CURRENT_FORMAT=" #I. #W#F "
%hidden STATUS_RIGHT_FORMAT=" @#H %e %h %H:%M "
%hidden STATUS_LEFT_FORMAT="[#S] "

# FORMAT REFERENCE
# ---------------------------------------------------------------
#H  Hostname of local host
#h  Hostname of local host (no domain name)
#D  Unique pane ID
#P  Index of pane
#T  Title of pane
#S  Name of session
#F  Window flags
#I  Index of window
#W  Name of window

# THEME REFERENCE
# ---------------------------------------------------------------
# Possible color values:
#   Hexadecimal: '#ffffff' (all 6 digits, no #FFF shorthand)
#   Terminal colors: black, red, green, yellow, blue, magenta, cyan, white
#   256-colour set: colour0 through colour255
#
# Possible attribute values:
#   none, bright, bold, dim, underscore, blink, reverse, hidden, italics,
#   strikethrough
# To disable an attribute, prefix with `no`, e.g. noreverse, noitalics.
#
# Style examples:
#   fg=yellow,bold,underscore,blink
#   bg=black,fg=default,noreverse
#
# Common style options:
#   pane-border-style
#   pane-active-border-style
#   window-style
#   window-active-style
#   window-status-style
#   window-status-current-style
#   window-status-activity-style
#   window-status-last-style
#   status-style
#   status-left-style
#   status-right-style
#   message-style
#   mode-style

# Panes
# ---------------------------------------------------------------
# Set inactive/active window styles.
# Style = comma-separated list of characteristics.
#
# IMPORTANT: use double quotes around style strings that contain variables.
# Variable substitution does not work reliably in single-quoted style strings.
# Example:
#   set -g pane-active-border-style "fg=${PANE_ACTIVE_BORDER_FG},bg=${PANE_ACTIVE_BORDER_BG}"

# Inactive Pane
set -g window-style "fg=${WINDOW_FG},bg=${WINDOW_BG}"

# Active Pane
set -g window-active-style "fg=${WINDOW_ACTIVE_FG},bg=${WINDOW_ACTIVE_BG}"

# Pane borders
set -g pane-border-style "fg=${PANE_BORDER_FG},bg=${PANE_BORDER_BG}"
set -g pane-active-border-style "fg=${PANE_ACTIVE_BORDER_FG},bg=${PANE_ACTIVE_BORDER_BG}"

# Status Bar
# ---------------------------------------------------------------
# The status bar that shows at the bottom.
# You can style left/right separately.
set -g status-style "fg=${STATUS_FG},bg=${STATUS_BG}"
set -g status-left-style "fg=${STATUS_LEFT_FG},bg=${STATUS_LEFT_BG}"
set -g status-right-style "fg=${STATUS_RIGHT_FG},bg=${STATUS_RIGHT_BG}"

# Align the window names: left | centre | right
set -g status-justify left

# Window titles in status bar
set -g window-status-style "fg=${WINDOW_STATUS_FG},bg=${WINDOW_STATUS_BG}"
set -g window-status-current-style "fg=${WINDOW_STATUS_CURRENT_FG},bg=${WINDOW_STATUS_CURRENT_BG}"

# Separator between window titles.
# Sets the separator drawn between windows in the status line. 
# The default is a single space character.
# NOTE: this separator shows after the window title. It'll still show even if
# there is only one window, e.g. `[0:bash]* ---` (where --- is the separator).
set -g window-status-separator "${WINDOW_STATUS_SEPARATOR}"

# Listing format for window names in the status bar.
# Default is `#I:#W#F`.
set -g window-status-format "${WINDOW_STATUS_FORMAT}"
set -g window-status-current-format "${WINDOW_STATUS_CURRENT_FORMAT}"

# Left/right status contents
# ---------------------------------------------------------------
# By default, the current pane title in double quotes, the date and the time are shown. 
# string will be passed to strftime(3) and character pairs are replaced.

# status-right default is `\"#H\" %R %d-%h-%y`.
set -g status-right "${STATUS_RIGHT_FORMAT}"

# status-left default is `#S` (name of current session).
set -g status-left "${STATUS_LEFT_FORMAT}"

# LINKS
# ---------------------------------------------------------------
# Tmux Manual - http://man7.org/linux/man-pages/man1/tmux.1.html
# Time Variables - https://man.openbsd.org/strftime.3
