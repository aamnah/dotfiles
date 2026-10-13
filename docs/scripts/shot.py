#!/usr/bin/env python3
"""Screenshot a terminal program as a PNG, drawn like kitty with the Lasik theme.

Runs the command in a pseudo-terminal, reads what it draws through pyte (a
virtual terminal), renders the screen as HTML with Hasklug Nerd Font Mono and
the Lasik colours, then screenshots that HTML with headless Chrome and crops it.

Needs: Python 3, headless Google Chrome, and the Hasklug Nerd Font installed.
pyte and pillow come in through uv, so nothing is installed globally:

  uv run --with pyte --with pillow python3 docs/scripts/shot.py \
      OUT.png COLS ROWS WAIT_SECONDS [--keys "after_seconds:text" ...] -- command args...

  --keys sends input while it runs (\\r = Enter), e.g. --keys "2:\\r" "3:\\r"

The commands used for the screenshots on the docs site are on the Contributing page.
Run programs with a throwaway HOME (see there), so nothing personal ends up in a picture.
"""
import html, os, pty, re, select, subprocess, sys, tempfile, time
import pyte
from PIL import Image

# The repo root, worked out from this file (docs/scripts/shot.py), so it runs from any clone
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
THEME = f"{REPO}/.config/kitty/themes/lasik.conf"
FONT = '"Hasklug Nerd Font Mono", monospace'


class QuietScreen(pyte.Screen):
    # Programs ask the terminal "are you there?" (DSR 5) and "where's the
    # cursor?" (DSR 6). Neovim complains if nobody answers, so answer through
    # the pseudo-terminal like a real terminal would. `reply` is set in run().
    reply = None

    def report_device_status(self, mode, private=False, **kwargs):
        if self.reply is None:
            return
        if mode == 5:
            self.reply("\x1b[0n")
        elif mode == 6:
            mark = "?" if private else ""
            self.reply(f"\x1b[{mark}{self.cursor.y + 1};{self.cursor.x + 1}R")

    # Vim asks the terminal about its keyboard mode with a "private" colour
    # code (CSI > … m) that pyte's colour handler doesn't accept. It doesn't
    # change any colours, so skip it.
    def select_graphic_rendition(self, *attrs, private=False):
        if not private:
            super().select_graphic_rendition(*attrs)


def theme_colors():
    names = ["black", "red", "green", "brown", "blue", "magenta", "cyan", "white"]
    colors = {"foreground": "#cccccc", "background": "#01030a"}
    for line in open(THEME):
        m = re.match(r"\s*(color\d+|foreground|background)\s+(#[0-9a-fA-F]{6})", line)
        if m:
            colors[m.group(1)] = m.group(2)
    for i, n in enumerate(names):
        colors[n] = colors.get(f"color{i}", "#888888")
        colors["bright" + n] = colors.get(f"color{i + 8}", colors[n])
    return colors


def run(cmd, cols, rows, wait, keys):
    screen = QuietScreen(cols, rows)
    stream = pyte.ByteStream(screen)
    pid, fd = pty.fork()
    if pid == 0:
        os.environ.update(TERM="xterm-256color", COLORTERM="truecolor",
                          COLUMNS=str(cols), LINES=str(rows))
        os.execvp(cmd[0], cmd)
    screen.reply = lambda text: os.write(fd, text.encode())
    import fcntl, struct, termios
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
    start = time.time()
    pending = sorted(keys)
    while time.time() - start < wait:
        while pending and time.time() - start >= pending[0][0]:
            os.write(fd, pending.pop(0)[1].encode())
        r, _, _ = select.select([fd], [], [], 0.1)
        if r:
            try:
                stream.feed(os.read(fd, 65536))
            except OSError:
                break
    # Don't cut a redraw in half: keep reading until the program has been
    # quiet for 0.3 s (at most 2 s more). Without this, a big screen can be
    # captured while it's still being drawn.
    quiet_until = time.time() + 2
    while time.time() < quiet_until:
        r, _, _ = select.select([fd], [], [], 0.3)
        if not r:
            break
        try:
            stream.feed(os.read(fd, 65536))
        except OSError:
            break
    try:
        os.kill(pid, 9)
    except ProcessLookupError:
        pass
    return screen


def to_html(screen, colors):
    def color(value, default):
        if value == "default":
            return default
        if re.fullmatch(r"[0-9a-fA-F]{6}", value):
            return "#" + value
        return colors.get(value, default)

    rows = []
    for y in range(screen.lines):
        line = screen.buffer[y]
        cells = []
        for x in range(screen.columns):
            ch = line[x]
            fg, bg = color(ch.fg, colors["foreground"]), color(ch.bg, colors["background"])
            if ch.bold and ch.fg in ("black", "red", "green", "brown", "blue", "magenta", "cyan", "white"):
                fg = colors.get("bright" + ch.fg, fg)
            if ch.reverse:
                fg, bg = bg, fg
            style = f"color:{fg};background:{bg}"
            if ch.bold:
                style += ";font-weight:bold"
            if ch.italics:
                style += ";font-style:italic"
            if ch.underscore:
                style += ";text-decoration:underline"
            cells.append(f'<span style="{style}">{html.escape(ch.data or " ")}</span>')
        rows.append("".join(cells))
    bg = colors["background"]
    # Page background is magenta so the crop can find the terminal's edges
    return f"""<!doctype html><meta charset="utf-8"><style>
body{{margin:0;background:#ff00ff}}
pre{{display:inline-block;margin:0;padding:14px 16px;background:{bg};
font:14px/18px {FONT};font-variant-ligatures:normal}}
/* Each cell is a full-height block, so a background colour fills the whole
   line height. As plain inline text, the background only covers the letter
   height and thin stripes show between lines. */
pre div{{height:18px;white-space:pre}}
pre span{{display:inline-block;height:18px;vertical-align:top}}
</style><pre>{"".join(f"<div>{r}</div>" for r in rows)}</pre>"""


def main():
    args = sys.argv[1:]
    sep = args.index("--")
    head, cmd = args[:sep], args[sep + 1:]
    out, cols, rows, wait = head[0], int(head[1]), int(head[2]), float(head[3])
    keys = []
    if "--keys" in head:
        for spec in head[head.index("--keys") + 1:]:
            t, text = spec.split(":", 1)
            keys.append((float(t), text.encode().decode("unicode_escape")))
    screen = run(cmd, cols, rows, wait, keys)
    with tempfile.TemporaryDirectory() as tmp:
        page = os.path.join(tmp, "shot.html")
        open(page, "w").write(to_html(screen, theme_colors()))
        raw = os.path.join(tmp, "raw.png")
        subprocess.run(["google-chrome", "--headless", "--disable-gpu", "--hide-scrollbars",
                        "--window-size=2400,1400", f"--screenshot={raw}", f"file://{page}"],
                       stderr=subprocess.DEVNULL, check=True)
        img = Image.open(raw).convert("RGB")
        # Everything that isn't the magenta page background is the terminal
        px = img.load()
        w, h = img.size
        right = max(x for x in range(w) if px[x, 5] != (255, 0, 255))
        bottom = max(y for y in range(h) if px[5, y] != (255, 0, 255))
        img.crop((0, 0, right + 1, bottom + 1)).save(out)
    print("saved", out)


main()
