---
title: Known issues
description: Bugs and gaps that are known but not fixed yet, with workarounds.
---

Things that don't work as they should yet. Each has a workaround.

## Installer

| Issue | Effect | Workaround |
|---|---|---|
| **Some steps stop the whole install on failure** — starship install, TPM/Catppuccin `git clone`, a missing source file in `--remote` mode | a network hiccup there stops everything after it | re-run; finished steps are skipped |
| **Not tested as a normal user with `sudo`** | password prompts from `sudo`/`chsh` haven't been tried end to end | run as root in a container to test, or report problems |
| **macOS not re-tested** since the interactive installer was added | probably fine — bash 3.2 compatible — but unverified | report problems |
| `.vimrc`, `.gitconfig`, `.gitignore_global`, tmuxp and peaclock configs **aren't installed** | you have to copy them by hand | see each page under Editors / Tools |

## Configs

| Issue | Effect | Workaround |
|---|---|---|
| `.vimrc` uses **`sublimemonokai`**, which isn't included | `E185` error when Vim starts | [install it or switch scheme](/dotfiles/editors/vim/) |
| `.gitconfig` doesn't set **`core.excludesfile`** | `.gitignore_global` has no effect | [one command](/dotfiles/tools/git/#gitignore_global) |
| kitty's Catppuccin file is **`catppucin-mocha.conf`** but the commented `include` says `catppuccin-mocha.conf` | switching themes by uncommenting fails | rename the file or fix the line |
| Neovim comment says "Use spaces" but **`expandtab = false`** (tabs) | confusing; tabs are used | set `true` for spaces |
| **Neovim indents with tabs**, Vim and nano with 4 spaces | files differ depending on the editor | set `expandtab = true` in `init.lua` |
| `tmux.conf` comment says **prefix + i** for plugins | TPM's key is **capital I** | press Prefix + Shift+I |
| `.bash_profile` adds the **Android SDK** to `PATH` unconditionally | harmless extra `PATH` entries on machines without it | — |
| **`~/.zsh_secrets` is zsh-only** | bash doesn't load your secrets | [source it from a bash local file](/dotfiles/shell/local-files/#secrets) |
| `.zshrc.local.example` repeats Homebrew and nvm setup that's now in `.zshenv` | copying it as-is loads them twice | use it as a reference only |

## Behaviour to be aware of

These work as designed but can surprise you:

- [`cc`](/dotfiles/shell/aliases/#tools) hides the C compiler and [`ip`](/dotfiles/shell/aliases/#network)
  hides Linux's `ip` command at the prompt.
- **kitty's Ctrl+Shift+H/J/K/L/-** defaults are replaced by split navigation — see
  [kitty](/dotfiles/terminal/kitty/#splits-like-tmux).
- **`LC_ALL` is set**, which overrides per-category locale settings like `LC_TIME` — see
  [Locale](/dotfiles/shell/locale/#edge-cases).
- **Your old `~/.bashrc` is replaced** (backed up) — move custom bits to `~/.aliases.local`.
- **Arch:** the first run on a never-synced system does a **full upgrade** (`pacman -Syu`),
  because Arch doesn't support partial upgrades.
- **"Desktop" detection** uses `$DISPLAY` / `$WAYLAND_DISPLAY`. Running the installer over SSH
  *into* a Linux desktop counts as a server: no kitty warning, no `notify-send`.
- **In the Arch Docker image** only a few locales can be generated — see
  [Locale](/dotfiles/shell/locale/#edge-cases).
