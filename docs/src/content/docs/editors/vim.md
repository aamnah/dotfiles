---
title: Vim
description: .vimrc — line numbers, 2-space indents, mouse, folding, smart search. Not installed automatically.
---

`.vimrc` is a classic Vim config. **The installer doesn't copy it** — for Neovim, see
[Neovim](/dotfiles/editors/neovim/), which is installed.

To use it:

```sh
cp .vimrc ~/.vimrc
```

:::caution[Missing colour scheme]
`.vimrc` sets `colorscheme sublimemonokai`, which isn't in the repo. Without it Vim shows
`E185: Cannot find color scheme 'sublimemonokai'` every time it starts (press Enter to
continue). Either install it:

```sh
mkdir -p ~/.vim/colors
curl -fsSLo ~/.vim/colors/sublimemonokai.vim \
  https://raw.githubusercontent.com/ErichDonGubler/vim-sublime-monokai/master/colors/sublimemonokai.vim
```

or change the line to a built-in scheme: `colorscheme habamax` (Vim 9+) or `colorscheme desert` (any Vim).
:::

## Settings

| Area | Settings |
|---|---|
| Display | line numbers, cursor position, window title, wrapped lines, 2-line command area, status line always on |
| Width | window 120 columns wide, guide line at column 90 |
| Indent | **4 spaces**, auto and smart indent, follows file type (`filetype indent on`) |
| Mouse | on (`mouse=a`) |
| Search | highlight matches, search as you type, ignore case unless you type a capital |
| Folding | fold column on, `{{{ }}}` markers, everything open when a file loads |
| History | 1000 commands, 1000 undo levels, hidden buffers |
| Encoding | UTF-8 |
| Auto-reload | files changed outside Vim reload when the cursor stops moving |

## Edge cases

- **`set columns=120`** resizes the *terminal window* in some terminals (or does nothing in
  others). Remove it if Vim fights your window size.
- **`set t_Co=256`** forces 256 colours; on very old terminals colours may look wrong.
- `set number`, `set ruler` and `syntax on` appear twice — harmless duplicates.
- **Neovim indents differently**: Vim and [nano](/dotfiles/editors/nano/) use 4 spaces, but
  [Neovim](/dotfiles/editors/neovim/) uses real tab characters (shown 4 wide).
