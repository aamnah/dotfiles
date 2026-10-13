---
title: What gets installed
description: Every file the installer copies, every package it may install, and what it deliberately leaves alone.
---

## Config files

Each file is copied from the repo to the same path under your home folder. An existing file is
backed up first as `<file>.bak.<timestamp>`.

| Repo file | Installed to | Page |
|---|---|---|
| `.zshrc`, `.zshenv`, `.zprofile` | `~/` | [zsh](/dotfiles/shell/zsh/) |
| `.bash_profile`, `.bashrc`, `.inputrc` | `~/` | [bash](/dotfiles/shell/bash/) |
| `.aliases`, `.functions` | `~/` | [Aliases](/dotfiles/shell/aliases/), [Functions](/dotfiles/shell/functions/) |
| `.config/nano/nanorc` | `~/.nanorc` (path rewritten for your OS) | [nano](/dotfiles/editors/nano/) |
| `.tmux.conf` | `~/.tmux.conf` | [tmux](/dotfiles/terminal/tmux/) |
| `.config/tmux/*.tmux`, `tmux.conf` | `~/.config/tmux/` | [tmux](/dotfiles/terminal/tmux/) |
| `.config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | [kitty](/dotfiles/terminal/kitty/) |
| `.config/kitty/themes/*.conf` | `~/.config/kitty/themes/` (Lasik, Catppuccin Mocha) | [kitty](/dotfiles/terminal/kitty/#theme) |
| `.vimrc` | `~/.vimrc` | [Vim](/dotfiles/editors/vim/) |
| `.config/nvim/init.lua` | `~/.config/nvim/init.lua` | [Neovim](/dotfiles/editors/neovim/) |
| `.config/tmuxp/default.yaml` | `~/.config/tmuxp/default.yaml` | [tmuxp](/dotfiles/tools/tmuxp/) |
| `.config/peaclock/config` | `~/.config/peaclock/config` | [peaclock](/dotfiles/tools/peaclock/) |
| `.gitignore_global` | `~/.gitignore_global` | [Git](/dotfiles/tools/git/#gitignore_global) |
| `.gitconfig` | **not copied**: its settings are added to yours one by one, and settings you already have are kept | [Git](/dotfiles/tools/git/#what-the-installer-does) |
| `.config/starship.toml` | `~/.config/starship.toml` | [Starship](/dotfiles/terminal/starship/) |
| *(generated)* | `~/.config/locale.conf` | [Locale](/dotfiles/shell/locale/) |

Both the zsh and the bash files are always installed, whichever login shell you pick — so
switching shells later needs no re-install.

## Programs and packages

Only installed when missing. Already-installed ones are reported as `found:` and left alone.

| What | When | Why |
|---|---|---|
| **zsh** | zsh chosen as login shell | the shell itself |
| **starship** | always (via `brew`, or the official `starship.rs` installer) | the prompt |
| **less** | Linux | pager; `lesspipe` hooks into it |
| **bash-completion** | Linux | Tab-completion for `git`, `apt`, `ssh` hosts… |
| **notify-send** (`libnotify-bin` / `libnotify`) | Linux **desktops** only | the [`alert`](/dotfiles/shell/aliases/#alert) alias |
| **kitty terminfo** (`kitty-terminfo`) | Linux, when kitty itself isn't installed | so SSH from kitty works — see [kitty](/dotfiles/terminal/kitty/#using-kitty-over-ssh) |
| **A Nerd Font** (Hasklug by default) | desktops, when it isn't installed yet | icons in the prompt, tmux and kitty; goes to `~/.local/share/fonts` (Linux) or `~/Library/Fonts` (macOS), no `sudo` |
| **locale** (`locales`, `glibc-langpack-*`, `glibc-locale`) | chosen locale missing | see [Locale](/dotfiles/shell/locale/) |
| **chsh** (`util-linux-user` / `shadow`) | Fedora / Alpine, when missing | to change the login shell |
| **TPM** and **Catppuccin for tmux** | `git` is installed | cloned into `~/.config/tmux/plugins/` |

A *desktop* here means macOS, or Linux with a graphical session running (`$DISPLAY` or
`$WAYLAND_DISPLAY` is set). Over plain SSH and in Docker these are empty.

## System changes

| Change | When |
|---|---|
| Login shell changed with `chsh` | unless you pick **keep**, or it's already that shell |
| Shell path added to `/etc/shells` | only if `chsh` would refuse it otherwise (e.g. Homebrew's zsh) |
| Locale enabled in `/etc/locale.gen` and generated | Debian, Ubuntu, Arch, when the locale is missing |
| Full system upgrade (`pacman -Syu`) | **Arch only**, and only when the package database has never been synced (fresh images) |

## Not installed

These are in the repo but the installer doesn't copy them:

| File | Why it matters | Page |
|---|---|---|
| `.zshrc.local.example` | template for machine-specific settings | [Local files](/dotfiles/shell/local-files/) |
| `docs/` | this site | [Contributing](/dotfiles/reference/contributing/) |

`kitty`, `tmux`, `vim`, `nvim`, `tmuxp` and `peaclock` themselves are **not** installed, only
their configs. You get a
warning with the install command if they're missing (the kitty warning only appears on desktops,
since kitty is a desktop app).
