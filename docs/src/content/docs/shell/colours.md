---
title: Colours & Ubuntu defaults
description: lesspipe, dircolors, coloured completion and other defaults ported from Ubuntu's .bashrc.
---

Installing these dotfiles **replaces** your `~/.bashrc`, so useful parts of Ubuntu's default
`.bashrc` (from Ubuntu 26.04 LTS, `/etc/skel/.bashrc`) were ported into `.bash_profile` — and to
`.zshrc` too, so both shells match.

| Default | bash | zsh | What it does |
|---|---|---|---|
| History settings, `checkwinsize` | ✅ | own equivalents | see [bash](/dotfiles/shell/bash/) |
| `ls` / `grep` colour aliases, `ll`, `la`, `l` | ✅ | ✅ | see [Aliases](/dotfiles/shell/aliases/) |
| `lesspipe` | ✅ | ✅ | `less` can show archives, PDFs, images |
| `dircolors` | ✅ | ✅ | colour scheme for `ls` |
| bash-completion | ✅ | — (zsh has its own) | smart Tab completion |
| Coloured completion lists | — (bash can't) | ✅ | Tab menu uses `ls` colours |
| `alert` | ✅ | ✅ | [desktop notification](/dotfiles/shell/aliases/#alert) |
| `debian_chroot` prompt prefix | — | — | skipped: only matters inside chroots |
| Ubuntu's coloured prompt | — | — | replaced by [Starship](/dotfiles/terminal/starship/) |

Each one only runs if the program exists, so nothing breaks on macOS or minimal servers.

## `lesspipe`

`less file.tar.gz` normally shows unreadable binary. With `lesspipe`, it shows the archive's
file list instead; the same for PDFs (as text), images (their details) and more.

```sh
eval "$(SHELL=/bin/sh lesspipe)"
```

`lesspipe` prints two `export` lines that tell `less` to use it. `SHELL=/bin/sh` makes sure
those lines are in plain `sh` syntax, which both bash and zsh understand.

## `dircolors`

GNU `ls --color` takes its colours from the `LS_COLORS` variable. `dircolors` sets it:

- With `~/.dircolors`, that file's scheme is used. Make one to customise:
  `dircolors -p > ~/.dircolors`
- Without it, the built-in scheme is used.

Not available on macOS — there, `CLICOLOR=1` turns on colours for BSD `ls`.

## Coloured completion (zsh)

```sh
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
```

Makes the zsh Tab menu colour folders, links and executables the same way `ls` does.
`${(s.:.)LS_COLORS}` splits `LS_COLORS` at each `:` into the list format zsh wants.
