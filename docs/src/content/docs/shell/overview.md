---
title: Shell overview
description: How the bash and zsh configs are organised, which file loads when, and why aliases and functions are shared.
---

The repo supports **bash** and **zsh** with feature parity — the same aliases, functions and
prompt in both. Use zsh on your laptop and bash on a server; nothing to relearn.

zsh is the default shell on **macOS** (since Catalina, 2019) and **Kali Linux**. Ubuntu, Debian,
Fedora, Arch, Alpine and the usual Docker images default to bash (or plain `sh`). The installer
installs zsh for you if you pick it — see [Install](/dotfiles/start/install/).

## Which file loads when

A shell reads different startup files depending on *how* it was started:

- **Login shell** — the first shell after you log in: SSH, a console login, macOS Terminal.
- **Interactive shell** — one you type into: every new terminal tab.
- **Non-interactive** — scripts, cron jobs, `ssh host 'some command'`, editors running commands.

```
                      zsh                              bash
                      ───                              ────
every zsh       →  ~/.zshenv                     (no equivalent)
login           →  ~/.zprofile                   ~/.bash_profile  ← all real config
interactive     →  ~/.zshrc                      ~/.bashrc  ──→ loads ~/.bash_profile
                      │                                │
                      └──── both load ────┬────────────┘
                                          ▼
                    ~/.aliases   ~/.functions   (+ *.local versions)
```

| zsh | runs when | bash equivalent | what goes here |
|---|---|---|---|
| `.zshenv` | **every** zsh — interactive, login, scripts, cron, GUI apps | none | `PATH`, environment variables everything needs |
| `.zprofile` | login shells, **before** `.zshrc` | `.bash_profile` | once-per-login setup (`ssh-agent`, tmux auto-attach) |
| `.zshrc` | interactive shells (every new tab) | `.bashrc` | aliases, functions, prompt, completion, key bindings |
| `.zlogin` | login shells, **after** `.zshrc` | `.bash_login` (rare) | login setup that needs the shell fully configured |
| `.zlogout` | leaving a login shell | `.bash_logout` | cleanup |

This repo ships `.zshenv`, `.zprofile` and `.zshrc`. `.zlogin` and `.zlogout` aren't used.

### Why the split matters

Most personal config can live in `.zshrc`. The split matters when:

- **Something must run only once per session.** The classic example is `ssh-agent`: in `.zshrc`
  every new tab starts a new agent; in `.zprofile` every tab shares the same one.
- **Something must be visible outside the prompt.** Cron jobs, GUI apps and scripts only read
  `.zshenv`. That's why `PATH` lives there — a cron job calling a Homebrew tool would fail if
  Homebrew's `PATH` was only set in `.zshrc`.

bash has no file that runs for every invocation (no `.bash_env` equivalent). Its split is
login (`.bash_profile`) vs. interactive (`.bashrc`). This repo puts everything in
`.bash_profile` and makes `.bashrc` load it — see [bash](/dotfiles/shell/bash/#bashrc).

## Shared aliases and functions

`.aliases` and `.functions` are **one file each, loaded by both shells**. Shell-specific bits
sit behind a check:

```sh
if [[ -n "$ZSH_VERSION" ]]; then
  alias dang='sudo $(fc -ln -1)'          # zsh way to get the last command
elif [[ -n "$BASH_VERSION" ]]; then
  alias dang='sudo $(history -p \!\!)'    # bash way
fi
```

`$ZSH_VERSION` and `$BASH_VERSION` are set by the shell itself and aren't exported, so exactly
one of them is set in any given shell.

### File naming

Names without a `bash_` or `zsh_` prefix (`.aliases`, `.functions`) signal "works in both".
Keeping one shared file avoids two copies drifting apart. The shell doesn't care about the
name — it loads whatever path the startup file points to.

`.zshrc` also still loads the older names (`.zsh_aliases`, `.zsh_functions` and their `.local`
versions) if they exist, so an old setup keeps working.

## Detecting Linux vs. macOS

Many commands differ between GNU (Linux) and BSD (macOS) — `ls` colour flags, how to lock the
screen, where the Trash lives. The configs detect the OS once and set `IS_LINUX` or `IS_MACOS`;
aliases then pick the right command.

There are two ways to detect the OS:

| | `$OSTYPE` | `$(uname -s)` |
|---|---|---|
| Works in | bash, zsh | every shell, including `sh`, `dash`, BusyBox `ash` |
| Cost | free — set by the shell | starts a small program, ~1–5 ms |

This repo uses `uname -s` (portable) but only runs it **once**: `.zshenv` sets the variables, and
`.aliases` skips its own check when they're already set:

```sh
# "$IS_MACOS$IS_LINUX" joins both into one string — empty only if neither is set.
# Same as [[ -z "$IS_MACOS" && -z "$IS_LINUX" ]], just shorter.
if [[ -z "$IS_MACOS$IS_LINUX" ]]; then
  case "$(uname -s)" in
    Darwin) IS_MACOS=1 ;;
    Linux)  IS_LINUX=1 ;;
  esac
fi
```

In bash there's no `.zshenv`, so `.aliases` does the check itself — once per shell start.

## Pages in this section

- [zsh](/dotfiles/shell/zsh/) — `.zshenv`, `.zprofile`, `.zshrc`
- [bash](/dotfiles/shell/bash/) — `.bash_profile`, `.bashrc`, `.inputrc`
- [Aliases](/dotfiles/shell/aliases/) and [Functions](/dotfiles/shell/functions/)
- [Locale](/dotfiles/shell/locale/) — language and formats
- [Colours & Ubuntu defaults](/dotfiles/shell/colours/) — `lesspipe`, `dircolors`, completion colours
- [Local files](/dotfiles/shell/local-files/) — machine-specific settings and secrets
