---
title: Known issues
description: Bugs and gaps that are known but not fixed yet, with workarounds.
---

Things that don't work as they should yet. Each has a workaround.

## Installer

| Issue | Effect | Workaround |
|---|---|---|
| **Not tested as a normal user with `sudo`** | password prompts from `sudo`/`chsh` haven't been tried end to end | run as root in a container to test, or report problems |
| **macOS not re-tested** since the interactive installer was added | probably fine — bash 3.2 compatible — but unverified | report problems |

## Configs

| Issue | Effect | Workaround |
|---|---|---|
| **nano doesn't switch to spaces for YAML** (YAML doesn't allow tabs) | a YAML file indented with Tab in nano breaks | indent YAML with spaces by hand, or use Vim / Neovim — see [nano](/dotfiles/editors/nano/#edge-cases) |

## Behaviour to be aware of

These work as designed but can surprise you:

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
