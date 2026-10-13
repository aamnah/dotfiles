---
title: tmuxp
description: A default 6-pane tmux layout (with a clock and the weather) loaded by the t function.
---

[tmuxp](https://github.com/tmux-python/tmuxp) opens tmux sessions from a layout file — which
windows, how they're split, what runs in each pane. The [`t`](/dotfiles/shell/functions/#t)
function uses it.

## The default layout

`.config/tmuxp/default.yaml` — three columns; the right one is split into a tall pane and a
bottom row with a clock and the weather:

```
┌──────────────┬─────────────┬──────────────┐
│              │             │              │
│              │             │      3       │
│      1       │      2      │              │
│              │             ├────────┬─────┤
│              │             │        │  5  │
│              │             │   4    ├─────┤
│              │             │        │  6  │
└──────────────┴─────────────┴────────┴─────┘
```

| Pane | Runs |
|---|---|
| 1 | a shell (gets the focus) |
| 2, 3, 4 | shells |
| 5 | [`peaclock`](/dotfiles/tools/peaclock/) — a terminal clock |
| 6 | the weather from [wttr.in](https://wttr.in), refreshed every hour (`watch -n 3600`) |

The weather location is `{jkl}` in the `curl` URL — change it to your own city or airport
code. The file also has a commented example of running several commands in one pane
(`nvm use lts`, setting `NODE_ENV`).

## Setup

The installer copies the layout to `~/.config/tmuxp/default.yaml`, but doesn't install tmuxp
itself:

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh     # uv: a fast Python tool installer
uv tool install tmuxp
```

Then in any project folder:

```sh
t
```

For a project-specific layout, put a `tmuxp.yaml` in that folder — `t` prefers it.

## Edge cases

- The layout string (`d861,305x53,…`) was captured from a **305×53** character window. On a much
  smaller window tmux squeezes the panes to fit.
- `.zshrc` sets `DISABLE_AUTO_TITLE=true` so window names from the layout aren't overwritten.
