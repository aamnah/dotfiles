---
title: Supported systems
description: Which operating systems and package managers the installer supports, and what has actually been tested.
---

## Operating systems

| System | Status | Package manager |
|---|---|---|
| Ubuntu (26.04 LTS tested) | ✅ tested | `apt` |
| Debian (stable) | ✅ tested | `apt` |
| Fedora | ✅ tested | `dnf` |
| Arch Linux | ✅ tested | `pacman` |
| openSUSE Tumbleweed | ✅ tested | `zypper` |
| Alpine | ✅ tested | `apk` |
| RHEL / CentOS / older Fedora | should work, untested | `yum` |
| Armbian (Raspberry Pi etc.) | should work (Debian-based), untested | `apt` |
| macOS — Apple Silicon | supported, not re-tested since the interactive installer | `brew` |
| macOS — Intel | supported, not re-tested since the interactive installer | `brew` |

Anything else (FreeBSD, Windows outside WSL…) stops with `error: unsupported OS`.
WSL counts as Linux.

**"Tested"** means: fresh official Docker image, installer run twice (the second run must
install nothing), then a login shell checked for the right locale and no warnings.

:::caution[Only tested as root so far]
All automated tests ran as `root` inside Docker containers. Running as a normal user — where
`sudo` and `chsh` ask for your password — hasn't been tested yet. It's designed to work
(password prompts read from your keyboard even under `curl | bash`), but if something goes wrong,
please open an issue.
:::

## Root vs. a normal user

Installing packages, generating locales and editing `/etc/shells` need root.

- **As root** (typical in Docker): commands run directly. Nothing asks for a password.
- **As a normal user**: commands run through `sudo`, which asks for your password once.
  `chsh` (change login shell) asks for your password too.
- **Normal user without `sudo`**: package installs are skipped with a warning. Config files are
  still installed — they don't need root.

## macOS notes

- **Homebrew is needed** to install anything (zsh, starship, nano). Without it you get a warning
  with the `brew install …` command to run later.
- **zsh ships with macOS** (default since Catalina, 2019), so it's never installed there.
- **bash on macOS is version 3.2** (from 2007 — Apple stopped updating it because newer versions
  use the GPLv3 licence). The installer and configs avoid newer bash features so they still
  work. Homebrew's `bash-completion` needs bash 4+, so it isn't installed on macOS.
- **macOS ships nano 2.0.6**, which doesn't understand most of the nano config. See
  [nano](/dotfiles/editors/nano/).
- Every locale is already installed on macOS, so nothing is generated.

## Alpine / BusyBox notes

- Alpine uses **musl** instead of glibc. musl doesn't need locales to be generated, and has no
  `locale` command — the configs detect this and skip the locale check.
- `less` is BusyBox's small version. It works, but has fewer features than GNU less.
- `chsh` isn't in BusyBox; the installer adds the `shadow` package to get it.
