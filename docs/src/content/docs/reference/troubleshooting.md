---
title: Troubleshooting
description: Error messages and odd behaviour, by symptom — and how to fix each one.
---

Search this page for the exact message you see (**Ctrl+F**), or use the site search.

## Installer

### The script stopped halfway

The installer stops at the first unexpected error. Most steps catch their own problems and just
warn, but a few don't yet — a network failure while installing **starship** or cloning the
**tmux plugins** stops everything after it ([known issue](/dotfiles/reference/known-issues/)).
Fix the network problem and run it again; it skips whatever is already done.

### It didn't ask me anything

It only asks when there's a keyboard to answer with. With `-y`, in Docker builds, CI, or when
input is redirected, it uses the defaults (zsh, `en_US.UTF-8`) and prints the plan without
asking. Run it directly in a terminal to get the questions.

### `error: --shell must be zsh, bash or keep` / `error: --locale must look like…`

A flag value wasn't recognised. Nothing was changed. Locales look like `fi_FI` or
`fi_FI.UTF-8`; shells are `zsh`, `bash` or `keep`.

### `warning: cannot install … — not root and sudo not found`

Installing packages needs root. Run as root, or install `sudo` and add yourself to the `sudo`
(Debian/Ubuntu) or `wheel` (Fedora/Arch) group. Config files are installed either way.

### `warning: chsh failed` / `note: no terminal to ask for your password`

Changing the login shell asks for your password. Without a terminal (e.g. `-y` from a script)
it can't ask. Run it yourself:

```sh
chsh -s "$(command -v zsh)"
```

### `error: target not found: …` (Arch)

The package database wasn't synced. The installer does this automatically on fresh systems; on
an existing system, update first: `sudo pacman -Syu`.

### Lots of `*.bak.*` files in my home folder

Each run backs up every file it replaces, with a new timestamp. Once you're happy:

```sh
ls ~/.*.bak.* ~/.config/*/*.bak.*     # check first
rm ~/.*.bak.*                          # then remove
```

## Shell

### My aliases don't work in a new terminal tab (bash)

New tabs on Linux are non-login shells and read `~/.bashrc`. Check it exists and loads
`~/.bash_profile`: `cat ~/.bashrc`. See [bash](/dotfiles/shell/bash/#bashrc).

### `setlocale: cannot change locale` / `perl: warning: Setting locale failed`

The locale isn't installed. The configs normally fall back to `C.UTF-8` automatically — if you
still see this, something else (an `/etc` file, an SSH client sending `LC_*`) sets it. See
[Locale](/dotfiles/shell/locale/#when-the-locale-isnt-installed).

### SSH from my Mac sets a strange locale on the server

macOS's SSH client sends your local `LANG`/`LC_*` to the server (`SendEnv LANG LC_*`). If the
server lacks that locale, you get warnings. The dotfiles override it on login; to stop sending
it, remove `SendEnv` from `/etc/ssh/ssh_config` on the Mac.

### `scp` or `rsync` fails with "protocol error" or strange output

Something prints text in a non-interactive shell. This repo's `.bashrc` stops early for
non-interactive shells; check your `~/.aliases.local`, `~/.functions.local` and
`~/.zshenv.local` for `echo` lines.

### `cc main.c` opens Claude instead of compiling

The [`cc` alias](/dotfiles/shell/aliases/#tools) replaces the C compiler at the prompt. Use
`gcc`, `clang` or `command cc`. Scripts and `make` aren't affected.

### `ip addr` doesn't work

The [`ip` alias](/dotfiles/shell/aliases/#network) replaces Linux's `ip` command. Use
`command ip addr`, or add `unalias ip` to `~/.aliases.local`.

### `npm: command not found` in a script (zsh)

`.zshenv` puts nvm's **default** Node version on `PATH`. If nvm has no default, there's nothing
to add:

```sh
nvm alias default 22      # or whichever version you use
```

### Changes to the configs don't show up

Open a new terminal, or reload in place with [`reload`](/dotfiles/shell/aliases/#system). A new
**login shell** (after `chsh`) needs a log out and back in.

### Tab completion is wrong or slow (zsh)

Rebuild the completion cache: `rm ~/.zcompdump && exec zsh`.

### Homebrew commands are missing (zsh)

The cached `brew shellenv` output may be stale: `rm ~/.cache/brew_shellenv`, then open a new
shell.

## Terminal

### `'xterm-kitty': unknown terminal type`

The server doesn't know kitty. Run the installer there (it adds `kitty-terminfo`), connect with
`kitten ssh`, or use `TERM=xterm-256color ssh …`. See
[kitty](/dotfiles/terminal/kitty/#using-kitty-over-ssh).

### kitty uses default colours, not Lasik

The theme files aren't installed. Copy `.config/kitty/themes/` to `~/.config/kitty/themes/` —
see [kitty](/dotfiles/terminal/kitty/#theme).

### Icons in the prompt or tmux show as boxes

The terminal font has no Nerd Font icons. Install **Hasklug Nerd Font** (or any Nerd Font) and
select it in your terminal.

### tmux: error about `catppuccin.tmux` on start

The Catppuccin plugin wasn't cloned (no `git` during install):

```sh
git clone -b v2.3.0 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
```

### tmux: CPU / weather don't show

Plugins aren't downloaded yet. In tmux press **Prefix I** (Ctrl+B, then capital I).

### `t` says "duplicate session"

A session for this folder already exists: `tmux attach -t <folder-name>`.

## Editors

### nano: `Unknown flag` or unknown colour errors

Your nano is too old — macOS ships 2.0.6. `brew install nano`. See
[nano](/dotfiles/editors/nano/#edge-cases).

### Vim: `E185: Cannot find color scheme 'sublimemonokai'`

The colour scheme isn't included — see [Vim](/dotfiles/editors/vim/) for the download or a
built-in alternative.

### Neovim doesn't copy to the system clipboard

Install a clipboard helper: `sudo apt install wl-clipboard` (Wayland) or `xclip` (X11). Check
with `:checkhealth provider`.
