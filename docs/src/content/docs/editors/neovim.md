---
title: Neovim
description: init.lua — relative line numbers, system clipboard, tabs shown 4 wide, rulers, blinking cursor.
---

[Neovim](https://neovim.io) is a modern Vim. Its config, `~/.config/nvim/init.lua`, is written
in Lua and has no plugins — just settings, each with a comment saying what it does and its
default.

The installer copies the config but **doesn't install Neovim**:
`sudo apt install neovim` or `brew install neovim`.

## Settings

| Area | Setting | Effect |
|---|---|---|
| Line numbers | `number` + `relativenumber` | current line shows its number; others show distance from it (handy for `5j`, `3k`) |
| | `cursorline` | highlight the cursor's line |
| | `signcolumn = "yes"` | always reserve the left column, so text doesn't jump when git or error signs appear |
| Colour | `termguicolors` | 24-bit colour |
| | `colorcolumn = "80,100,120,132"` | four guide lines, subtle dark grey |
| Mouse & clipboard | `mouse = "a"` | mouse everywhere |
| | `clipboard = "unnamedplus"` | copy/paste uses the **system clipboard** |
| Indent | `tabstop`, `shiftwidth`, `softtabstop` = 4 | indent width 4 |
| | `expandtab = false` | **real tab characters**, not spaces |
| | `autoindent`, `smartindent` | keep and guess indentation |
| Scrolling | `wrap = false` | long lines scroll sideways |
| | `scrolloff = 5`, `sidescrolloff = 8` | keep some lines/columns visible around the cursor |
| Search | `ignorecase` + `smartcase` | case-insensitive unless you type a capital |
| Splits | `splitbelow`, `splitright` | new splits open below / to the right |
| Speed | `updatetime = 250` | faster updates for diagnostics and plugins (default 4000 ms) |
| Cursor | `guicursor` | blinking block; thin bar in insert mode; underline in replace mode |

## Edge cases

- **Clipboard on Linux needs a helper program.** `unnamedplus` uses `wl-copy` (Wayland) or
  `xclip` / `xsel` (X11). Without one, yanking only fills Neovim's own register. Over SSH there's
  usually no clipboard at all. Check with `:checkhealth provider`.
- **Tabs, not spaces.** The comment next to `expandtab` says "Use spaces instead of tabs", but
  the value is `false`, which means **tabs**. Set it to `true` for spaces. Vim and nano in this
  repo use spaces — see [Vim](/dotfiles/editors/vim/#edge-cases).
- **The cursor shape** only changes in terminals that support it (kitty does). The
  `guicursor` block in `init.lua` has a long comment explaining every mode letter.
