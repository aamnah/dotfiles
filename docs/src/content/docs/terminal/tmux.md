---
title: tmux
description: tmux config — mouse, 1-based numbering, splits in the current folder, TPM plugins, Catppuccin and Lasik themes.
---

[tmux](https://github.com/tmux/tmux) keeps terminal sessions running in the background and
splits one terminal into panes. If your SSH connection drops, the session keeps running —
reattach with `tmux attach`.

The installer copies the config but **doesn't install tmux**. Install it with your package
manager (`sudo apt install tmux`, `brew install tmux`).

## Files

```
~/.tmux.conf                    one line: loads ~/.config/tmux/tmux.conf
~/.config/tmux/
├── tmux.conf                   the main config
├── reset.tmux                  clears theme settings before a theme loads
├── catppuccin.tmux             Catppuccin theme (the default)
├── lasik.tmux                  Lasik theme
└── plugins/                    TPM + plugins (cloned by the installer)
```

`~/.tmux.conf` is kept so older tmux versions (before 3.1), which don't look in `~/.config/tmux/`,
still find the config.

## Settings

The **prefix** is tmux's "listen to me" key — press it, release, then press the command key.
It's **Ctrl+B** (the default).

| Setting | Effect |
|---|---|
| Mouse on | click to select panes, drag borders to resize, scroll |
| Windows and panes start at **1** | `1` is easier to reach than `0` |
| `renumber-windows` | closing window 2 of 3 renames 3 → 2, no gaps |
| Pane titles on top | each pane shows ` 1: title ` — set with `tmux select-pane -T "logs"` |
| `extended-keys on` | lets apps tell **Shift+Enter** from Enter (needed by some coding agents) |
| 24-bit colour | `xterm-256color` plus RGB for kitty |

| Keys | Action |
|---|---|
| **Prefix "** | split top/bottom, in the current folder |
| **Prefix %** | split side by side, in the current folder |
| **Prefix c** | new window, in the current folder |
| **Prefix r** | reload the config **and** install any new plugins |
| **Prefix I** | install plugins (TPM's key) |

By default tmux opens new panes in your home folder; these bindings use the pane's current folder.

## Plugins (TPM)

**TPM** (Tmux Plugin Manager) downloads and loads plugins listed in `tmux.conf`. The installer
clones TPM into `~/.config/tmux/plugins/tpm` (if `git` is installed).

| Plugin | Shows |
|---|---|
| `tmux-plugins/tmux-cpu` | CPU and RAM use in the status bar |
| `xamut/tmux-weather` | temperature and an icon for **Jyväskylä** — change `@tmux-weather-location` |

After the first install, open tmux and press **Prefix I** (capital I, so Shift+i) to download the plugins.

## Themes

**Catppuccin** (Mocha flavour, rounded window tabs) is loaded by default. Its status bar shows
the session name on the left, and CPU, RAM, weather, host and date/time on the right. The
installer clones Catppuccin's tmux plugin, **version 2.3.0**, to
`~/.config/tmux/plugins/catppuccin/tmux`.

**Lasik** matches the author's [VSCode theme](https://github.com/aamnah/lasik-vscode-theme).
Its colours are defined once at the top of `lasik.tmux` as `%hidden` variables (tmux's own
variables, not shell ones) — edit those, not the individual `set -g` lines.

Switch themes in a running tmux:

```sh
tmux source-file ~/.config/tmux/lasik.tmux
tmux source-file ~/.config/tmux/catppuccin.tmux
```

To make Lasik the default, change the `source-file` line in `tmux.conf`.

`reset.tmux` runs first in every theme. tmux remembers style settings while it runs, so without
the reset, switching themes leaves old colours showing through.

## Edge cases

- **No `git` during install** → TPM and Catppuccin aren't cloned; you get the `git clone`
  commands to run later. Without Catppuccin, tmux shows an error on start until it's cloned.
- **`~/.config/tmux` is a file**, not a folder → the installer stops with an error for tmux.
- **The weather plugin** calls an online service; offline it shows nothing.
- `tmux-256color` would be more accurate than `xterm-256color`, but it's missing on older macOS.
- Kill the current session: [`kkk`](/dotfiles/shell/aliases/#tools). Start one per project:
  [`t`](/dotfiles/shell/functions/#t).
