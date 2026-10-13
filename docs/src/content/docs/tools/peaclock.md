---
title: peaclock
description: A binary clock, timer and stopwatch for the terminal. Config not installed automatically.
---

[peaclock](https://github.com/octobanana/peaclock) shows a big clock in the terminal — nice in a
spare tmux pane.

The config, `.config/peaclock/config`, sets:

| Setting | Value |
|---|---|
| View | **binary** (switch to `digital`, `ascii`, `date` or `icon`) |
| Time | 24-hour, with seconds and the date (`Tue 13 Oct - 02:30:05 pm`) |
| Size | fills the pane, keeping a 2:1 ratio |
| Colours | Lasik: light blocks on dark navy |
| Timer | 40 minutes; sends a desktop notification when done |

## Setup

Not installed by the installer. peaclock is built from source — see its
[README](https://github.com/octobanana/peaclock#build). Then:

```sh
mkdir -p ~/.config/peaclock && cp .config/peaclock/config ~/.config/peaclock/
peaclock
```

The [`peaclock` alias](/dotfiles/shell/aliases/#tools) adds `--config-dir ~/.config/peaclock`
so it finds this config.

The timer's notification uses `notify-send`, so it only works on Linux desktops.
