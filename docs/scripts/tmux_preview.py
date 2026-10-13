#!/usr/bin/env python3
"""Render two tmux themes side by side as an HTML page.

Each theme runs in its own throwaway tmux server (separate -L socket, so the
user's running tmux is never touched). The screen is read through pyte, a
virtual terminal that understands tmux's colour codes, then drawn as HTML.

Usage (pyte comes in through uv, nothing is installed globally):

  uv run --with pyte python3 docs/scripts/tmux_preview.py preview.html \
      "Repo=.config/tmux/lasik.tmux" "Mine=$HOME/.config/tmux/lasik.tmux"

Open preview.html in a browser with the Hasklug Nerd Font installed. The status
bar shows this machine's hostname, so keep these previews out of the docs.
"""
import html, os, pty, re, select, subprocess, sys, time
import pyte


class QuietScreen(pyte.Screen):
    """pyte crashes on tmux's private status queries (CSI ? 6 n, "where's the
    cursor?"). We only want to read the screen, so ignore them."""
    def report_device_status(self, *args, **kwargs):
        pass

COLS, ROWS = 110, 22
HOME = os.path.expanduser("~")
# Colours from the repo's kitty theme (docs/scripts/ → repo root), so it works from any clone
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KITTY_THEME = f"{REPO}/.config/kitty/themes/lasik.conf"

# Text shown in the panes — identical for both themes, so only the theme differs
LEFT_PANE = r"""printf '%s\n' \
 'install.sh — main()' '' \
 '  detect_system' '  ask_questions' '  confirm_plan' '' \
 '  install_nano' '  install_tmux' '  install_kitty' \
 '  install_shell_common' '  set_login_shell' ''; sleep 600"""
RIGHT_PANE = r"""printf '%s\n' \
 '$ myip' 'Local        192.168.1.20' 'ifconfig.me  203.0.113.31' \
 'OpenDNS      203.0.113.31' '' '(this pane is inactive)'; sleep 600"""


def kitty_colors():
    """ANSI colour names → hex, plus foreground/background, from kitty's Lasik theme."""
    names = ["black", "red", "green", "brown", "blue", "magenta", "cyan", "white"]
    colors = {"foreground": "#cccccc", "background": "#01030a"}
    for line in open(KITTY_THEME):
        m = re.match(r"\s*(color\d+|foreground|background)\s+(#[0-9a-fA-F]{6})", line)
        if m:
            colors[m.group(1)] = m.group(2)
    for i, n in enumerate(names):
        colors[n] = colors.get(f"color{i}", "#888888")
        colors["bright" + n] = colors.get(f"color{i + 8}", colors[n])
    return colors


def start_session(socket, theme):
    """Start a detached tmux server with only this theme loaded."""
    conf = f"/tmp/tmux-preview-{socket}.conf"
    with open(conf, "w") as f:
        f.write(f"""
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*:RGB"
set -g base-index 1
set -g pane-base-index 1
set -g pane-border-status top
set -g pane-border-format " #{{pane_index}}: #{{pane_title}} "
set -g status-interval 1
source-file {theme}
run-shell {HOME}/.config/tmux/plugins/tmux-cpu/cpu.tmux
""")
    t = ["tmux", "-L", socket]
    subprocess.run(t + ["-f", conf, "new-session", "-d", "-s", "dotfiles", "-n", "code",
                        "-x", str(COLS), "-y", str(ROWS), LEFT_PANE], check=True)
    subprocess.run(t + ["split-window", "-h", "-t", "dotfiles:1", RIGHT_PANE], check=True)
    subprocess.run(t + ["select-pane", "-t", "dotfiles:1.1", "-T", "editor"], check=True)
    subprocess.run(t + ["select-pane", "-t", "dotfiles:1.2", "-T", "shell"], check=True)
    subprocess.run(t + ["new-window", "-d", "-t", "dotfiles:2", "-n", "docs", "sleep 600"], check=True)
    subprocess.run(t + ["select-pane", "-t", "dotfiles:1.1"], check=True)  # left pane active
    time.sleep(2)  # let the CPU plugin fill in its values


def capture(socket):
    """Attach in a pseudo-terminal and feed everything tmux draws into pyte."""
    screen = QuietScreen(COLS, ROWS)
    stream = pyte.ByteStream(screen)
    pid, fd = pty.fork()
    try:
        return _read_screen(socket, screen, stream, pid, fd)
    finally:
        subprocess.run(["tmux", "-L", socket, "kill-server"], stderr=subprocess.DEVNULL)


def _read_screen(socket, screen, stream, pid, fd):
    if pid == 0:
        os.environ["TERM"] = "xterm-256color"
        os.environ["COLUMNS"], os.environ["LINES"] = str(COLS), str(ROWS)
        os.execvp("tmux", ["tmux", "-L", socket, "attach", "-t", "dotfiles"])
    import fcntl, struct, termios
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", ROWS, COLS, 0, 0))
    end = time.time() + 3
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.2)
        if r:
            try:
                stream.feed(os.read(fd, 65536))
            except OSError:
                break
    return screen


def to_html(screen, colors):
    def color(value, default):
        if value == "default":
            return default
        if re.fullmatch(r"[0-9a-fA-F]{6}", value):
            return "#" + value
        return colors.get(value, default)

    rows = []
    for y in range(ROWS):
        line = screen.buffer[y]
        cells = []
        for x in range(COLS):
            ch = line[x]
            fg = color(ch.fg, colors["foreground"])
            bg = color(ch.bg, colors["background"])
            if ch.reverse:
                fg, bg = bg, fg
            weight = "font-weight:bold;" if ch.bold else ""
            cells.append(f'<span style="color:{fg};background:{bg};{weight}">{html.escape(ch.data or " ")}</span>')
        rows.append("".join(cells))
    return "\n".join(rows)


def main():
    out, themes = sys.argv[1], sys.argv[2:]
    colors = kitty_colors()
    panels = []
    for i, spec in enumerate(themes):
        label, theme = spec.split("=", 1)
        socket = f"preview{i}"
        start_session(socket, theme)
        panels.append((label, to_html(capture(socket), colors)))
    body = "".join(
        f'<figure><figcaption>{html.escape(label)}</figcaption><pre>{grid}</pre></figure>'
        for label, grid in panels)
    open(out, "w").write(f"""<!doctype html><meta charset="utf-8"><style>
body{{margin:0;padding:20px;background:#15171c;display:flex;gap:24px;font-family:system-ui,sans-serif}}
figure{{margin:0}} figcaption{{color:#e6edf3;font-size:15px;font-weight:600;margin:0 0 8px}}
pre{{margin:0;padding:0;line-height:17px;font:13.5px/17px "Hasklug Nerd Font Mono",monospace;background:{colors['background']};border:1px solid #2a324b}}
</style>{body}""")


main()
