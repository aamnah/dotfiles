#!/bin/bash
#-----------------------------------------------------------------------
#        Author: Aamnah
#          Link: https://aamnah.com
#       Version: 0.3.0
#          Date: 2014-06-21
#       Lastmod: 2026-04-25
#   Description: Bash shell functions — take, ii, getwebsite, spy, t (kept in parity with ~/.zsh_functions)
# Compatibility: Debian, Ubuntu, Armbian, macOS
#-----------------------------------------------------------------------

# take: create a dir (with parents if needed) and cd into it
# ---------------------------------------------------------
take () {
  mkdir -p "$1" && cd "$1"
}


# _ii_bar: render a 10-char ASCII usage bar, coloured by threshold
#   Usage: `_ii_bar <pct>` where pct is an integer 0-100
#   Colours: white <60%, yellow 60–84%, red ≥85%
# -------------------------------------------------------------------
_ii_bar() {
  local pct=$1
  local bars="||||||||||" spaces="          "
  local filled=$(( pct * 10 / 100 ))
  (( filled > 10 )) && filled=10
  (( filled < 0 ))  && filled=0
  local color='\033[0;37m'
  (( pct >= 85 )) && color='\033[0;31m'
  (( pct >= 60 && pct < 85 )) && color='\033[0;33m'
  printf "[${color}%s\033[0m%s]" "${bars:0:$filled}" "${spaces:0:$((10 - filled))}"
}

# ii: display a compact MOTD-style host summary
#   Cross-platform (Linux + macOS), self-contained colours, gracefully degrades
#   when commands or files are missing.
#   Inspired by: https://aamnah.com/notes/raspberrypi/howto-raspberry-pi-motd-message-of-the-day/
# -------------------------------------------------------------------
ii() {
  local RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m'
  local BLUE='\033[0;34m' MAGENTA='\033[0;35m' BOLD='\033[1m' RESET='\033[0m'
  local OS=$(uname -s)

  # Timestamp — JS Date.toString()-ish format (cross-platform: GNU `%-d` vs BSD `%e`)
  local datestr
  if [[ "$OS" == "Linux" ]]; then
    datestr=$(date +'%a %b %-d %Y %H:%M:%S GMT%z (%Z)')
  else
    datestr=$(date +'%a %b %e %Y %H:%M:%S GMT%z (%Z)' | sed 's/  / /')
  fi

  # OS / distro name (Linux: PRETTY_NAME from /etc/os-release; macOS: sw_vers)
  local os_name
  if [[ "$OS" == "Linux" && -r /etc/os-release ]]; then
    os_name=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/,"",$2); print $2}' /etc/os-release)
  elif [[ "$OS" == "Darwin" ]]; then
    os_name="macOS $(sw_vers -productVersion 2>/dev/null)"
  fi

  # Header — date, then hostname + kernel + os
  echo
  printf "  %s\n" "$datestr"
  printf "  ${BOLD}${RED}%s${RESET}  %s  %s\n" "$(hostname)" "$(uname -srm)" "${os_name:-}"
  echo

  # Network — local + public IP
  local local_ip
  if [[ "$OS" == "Linux" ]]; then
    local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  else
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "n/a")
  fi
  printf "  ${BLUE}Local IP   ${RESET}%s\n"  "${local_ip:-n/a}"
  printf "  ${BLUE}Public IP  ${RESET}%s\n"  "$(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo 'n/a')"

  # Uptime + load + processes
  local up loads
  if [[ "$OS" == "Linux" ]]; then
    up=$(uptime -p 2>/dev/null | sed 's/^up //')
    if [[ -r /proc/loadavg ]]; then
      read -r one five fifteen _ < /proc/loadavg
      loads="${one} / ${five} / ${fifteen}"
    fi
  else
    # macOS uptime: "12:34  up 2 days, 3:14, 1 user, load averages: 1.23 4.56 7.89"
    up=$(uptime | sed -E 's/^.*up //; s/, *[0-9]+ users?,.*//')
    loads=$(uptime | sed -E 's/.*load averages?: //; s/  +/ \/ /g')
  fi
  printf "  ${YELLOW}Uptime     ${RESET}%s\n"  "${up:-n/a}"
  printf "  ${YELLOW}Load       ${RESET}%s  (1m / 5m / 15m)\n"  "${loads:-n/a}"
  printf "  ${YELLOW}Processes  ${RESET}%s\n"  "$(ps ax | wc -l | tr -d ' ')"

  # Memory used/total + percent
  local mem mem_pct
  if [[ "$OS" == "Linux" ]]; then
    mem=$(free -h 2>/dev/null | awk '/^Mem:/{printf "%s / %s used", $3, $2}')
    mem_pct=$(free 2>/dev/null | awk '/^Mem:/{printf "%d", $3*100/$2}')
  else
    local pagesize total_b used_pages used_b total used
    pagesize=$(getconf PAGESIZE 2>/dev/null || echo 4096)
    total_b=$(sysctl -n hw.memsize 2>/dev/null)
    used_pages=$(vm_stat 2>/dev/null | awk '
      /Pages active/                  {a=$3+0}
      /Pages wired/                   {w=$4+0}
      /Pages occupied by compressor/  {c=$5+0}
      END {print a+w+c}
    ')
    used_b=$(( used_pages * pagesize ))
    total=$(awk -v b="$total_b" 'BEGIN{printf "%.1fG", b/1024/1024/1024}')
    used=$(awk -v b="$used_b"  'BEGIN{printf "%.1fG", b/1024/1024/1024}')
    mem="${used} / ${total} used"
    mem_pct=$(( total_b > 0 ? used_b * 100 / total_b : 0 ))
  fi
  printf "  ${MAGENTA}Memory     ${RESET}%s  %s\n" "$(_ii_bar "${mem_pct:-0}")" "${mem:-n/a}"

  # Disk usage (root) + percent
  local disk disk_pct
  disk=$(df -h / 2>/dev/null | awk 'NR==2{printf "%s / %s (%s used)", $3, $2, $5}')
  disk_pct=$(df / 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}')
  printf "  ${MAGENTA}Disk       ${RESET}%s  %s\n" "$(_ii_bar "${disk_pct:-0}")" "${disk:-n/a}"

  # Users currently logged in (distinct usernames, not pty sessions —
  # otherwise tmux panes and terminal tabs each count separately)
  local user_count session_count
  user_count=$(who | awk '{print $1}' | sort -u | wc -l | tr -d ' ')
  session_count=$(who | wc -l | tr -d ' ')
  printf "  ${GREEN}Users      ${RESET}%s logged in (%s sessions)\n" "$user_count" "$session_count"
  echo
}


# getwebsite: wget a whole website (mirror for offline reading)
#   -r              recursive
#   -p              page-requisites: images, CSS, JS, etc.
#   -k              convert links to point to local copies (offline-browsable)
#   -np             no-parent: don't crawl above the starting URL
#   -l 5            max recursion depth 5 (safety; prevents crawling forever)
#   -e robots=off   ignore robots.txt
#   -U mozilla      pretend to be a browser
#   --random-wait   randomise wait between requests (avoids tripping rate limiters)
#
#   Other useful flags worth knowing about:
#   --limit-rate=20k   throttle download speed
#   -b                 continue in background after logout
#   -o ~/wget.log      log to file
#
#   Note: only handles static HTML. Modern JS-heavy / SPA sites won't render —
#   for those, try `httrack`, `monolith` (single-file snapshot), or browser
#   DevTools "Save Page As → Webpage, Complete".
#   ---------------------------------------------------------
getwebsite () {
  wget --random-wait -r -p -k -np -l 5 -e robots=off -U mozilla "$1"
}


# spy: identify and search for active network connections
#   Usage: `spy 8080` or `spy chrome`
#
#   lsof flags:
#     -i        list Internet sockets
#     -P        show numeric ports (don't translate to service names)
#     +c 0      show full command names (default truncates to 9 chars)
#     +M        include portmapper registrations (where applicable)
#
#   awk: preserves the lsof header row (COMMAND PID USER FD TYPE...) while
#   filtering the body. Naive `grep` drops the header because it doesn't
#   match the search pattern — leaving you with unlabelled columns.
#     NR==1                                     → always print the header
#     index(tolower($0), tolower(pat))          → case-insensitive literal
#                                                 match (not regex, so IPs
#                                                 like 127.0.0.1 work as-is)
#
#   Note: without sudo, lsof only shows your own processes. For a
#   system-wide view, prefix with sudo (`sudo spy 8080`).
# ---------------------------------------------------------
spy () {
  lsof -i -P +c 0 +M | awk -v pat="$1" 'NR==1 || index(tolower($0), tolower(pat))'
}


# t: load a tmuxp layout for the current dir; fall back to a user default,
#    then to a plain tmux session. Sanitises session name (tmux disallows
#    . and : in names) and injects session_name / start_directory into the
#    loaded config when missing.
# -------------------------------------------------------------------
t() {
  local NAME="${PWD##*/}" # strip everything up to the last /, giving just the current folder name
  NAME="${NAME//[.:]/_}" # tmux session names can't contain . or :. If your folders might have those, sanitize

  # tmuxp missing — fall straight back to plain tmux
  if ! command -v tmuxp >/dev/null 2>&1; then
    echo "tmuxp not installed; starting plain tmux session" >&2
    tmux new -s "$NAME"
    return
  fi

  # Find a layout: project-local first, then user default
  local PROJECT_CONFIG="tmuxp.yaml"
  local DEFAULT_CONFIG="$HOME/.tmuxp/default.yaml"
  local CONFIG_FILE=""

  if [[ -f "$PROJECT_CONFIG" ]]; then
    CONFIG_FILE="$PROJECT_CONFIG"
    echo "Loading project layout: $PROJECT_CONFIG"
  elif [[ -f "$DEFAULT_CONFIG" ]]; then
    CONFIG_FILE="$DEFAULT_CONFIG"
    echo -e "No ${PROJECT_CONFIG} in current dir; loading default: $DEFAULT_CONFIG"
  else
    echo "No layout config found; starting plain tmux session"
    tmux new -s "$NAME"
    return
  fi

  # If config has session_name, load as-is
  #   ^session_name      — top-level key, not a nested/commented mention
  #   [[:space:]]        — portable across BSD/GNU grep (vs \s which isn't)
  if grep -qE '^session_name[[:space:]]*:' "$CONFIG_FILE"; then
    tmuxp load "$CONFIG_FILE"
    return
  fi

  # Otherwise: inject session_name (current dir) and start_directory ($PWD)
  # into a temp copy. tmuxp resolves relative paths relative to the config
  # file's location, so injecting start_directory keeps things correct when
  # the temp file lives in /tmp.
  #
  # tmuxp dispatches its parser by file extension (.yaml vs .json), so the
  # temp file MUST end in .yaml. GNU mktemp has --suffix; BSD mktemp doesn't.
  # Workaround: plain `mktemp` then `mv` to add the suffix — works on both.
  local tmp
  tmp=$(mktemp) || { echo "mktemp failed" >&2; return 1; }
  mv "$tmp" "${tmp}.yaml"
  tmp="${tmp}.yaml"
  {
    cat "$CONFIG_FILE"
    echo "session_name: $NAME"
    if ! grep -qE '^start_directory[[:space:]]*:' "$CONFIG_FILE"; then
      echo "start_directory: $PWD"
    fi
  } > "$tmp"
  tmuxp load "$tmp"
  rm -f "$tmp"
}
