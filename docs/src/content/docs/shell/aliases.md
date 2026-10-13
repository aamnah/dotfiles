---
title: Aliases
description: Every alias in .aliases — what it does, the command behind it, and how it differs on Linux and macOS.
---

`~/.aliases` is loaded by both bash and zsh. Where Linux and macOS need different commands, the
alias name stays the same and the right command is picked when the shell starts.

To see what an alias really runs: `alias ll` (or `type ll`).

## Folders

| Alias | What it does | Command |
|---|---|---|
| `desk` | go to Desktop | `cd $HOME/Desktop` |
| `dl` | go to Downloads | `cd $HOME/Downloads` |

## Listing files

| Alias | What it does | Linux | macOS |
|---|---|---|---|
| `ls` | short listing, sizes readable, type markers, colour | `ls -hF --color=auto` | `ls -hFG` |
| `ll` | everything, detailed | `ls -alhF --color=auto` | `ls -alhFG` |
| `l` | everything, in rows instead of columns | `ls -aFx --color=auto` | `ls -aFxG` |
| `la` | everything except `.` and `..` | `ls -A` | `ls -A` |
| `lsd` | folders only, including hidden ones | `ls -dl */ .[^.]*/` | same |

What the flags mean:

- `-a` all files, including hidden `.dotfiles` · `-A` same but without `.` and `..`
- `-l` long format (permissions, owner, size, date) · `-h` human sizes (`4.0K`, `2.3G`)
- `-F` adds a marker: `/` folder, `*` executable, `@` link, `=` socket, `|` pipe
- `-x` sorts across rows instead of down columns
- Colour: GNU `ls` (Linux) uses `--color=auto`; BSD `ls` (macOS) uses `-G`

`tree` colours its output by default in a terminal, so there's no alias. To keep colours
through a pager: `tree -C | less -R`.

## Search

| Alias | Command |
|---|---|
| `grep` | `grep --color=auto` |
| `egrep` | `grep -E --color=auto` |
| `fgrep` | `grep -F --color=auto` |

`--color=auto` colours matches only when you're looking at the terminal. `--color=always`
would also add colour codes when piped (`grep foo file | wc -l`), which breaks the next command.

## Tools

| Alias | What it does | Command |
|---|---|---|
| `c` | start Claude Code | `claude` |
| `kkk` | kill the current tmux session | `tmux kill-session` |
| `peaclock` | terminal clock with this repo's config | `peaclock --config-dir ~/.config/peaclock` |
| `ssh` | **inside kitty only:** SSH that copies kitty's terminfo to the server | `kitty +kitten ssh` |

It's `c`, not `cc`, on purpose: `cc` is the system C compiler, and an alias would hide it at the
prompt.

## Network

| Alias | What it does | Command |
|---|---|---|
| `netlisteners` | programs listening for connections | `lsof -i -P \| grep LISTEN` |
| `flushdns` | clear the DNS cache | Linux: `resolvectl flush-caches` (or the older `systemd-resolve`) · macOS: `dscacheutil -flushcache` + restart `mDNSResponder` |

Your local and public IP addresses, IPv4 and IPv6: [`myip`](/dotfiles/shell/functions/#myip) (a function).
There's no `ip` alias, so Linux's own `ip` command (`ip addr`, `ip route`) works as normal.

## System

| Alias | What it does | Linux | macOS |
|---|---|---|---|
| `afk` | lock the screen | `loginctl lock-session`, then `xdg-screensaver lock` | `CGSession -suspend` |
| `emptytrash` | empty the Trash | `~/.local/share/Trash/` | `/Volumes/*/.Trashes` (needs `sudo`) + `~/.Trash` |
| `cleanup` | delete `.DS_Store` files below this folder | `find . -type f -name '*.DS_Store' -ls -delete` | same |
| `chromekill` | close Chrome's tab processes to free memory (extensions survive) | matches `chrome --type=renderer` | matches `Chrome Helper --type=renderer` |
| `reload` | restart the shell as a login shell | `exec $SHELL -l` | same |
| `dang` | run the last command again with `sudo` (like `sudo !!`) | — | — |

`emptytrash`, `cleanup` and `chromekill` delete or kill without asking. `cleanup` prints each
file as it goes (`-ls`).

### `alert`

Shows a desktop notification when a long command finishes:

```sh
sleep 10; alert
```

The icon shows whether the command succeeded, and the message is the command itself. Only
defined when `notify-send` exists — Linux desktops. Not on servers or macOS. Comes from Ubuntu's
default `.bashrc`.

## Disk and memory

| Alias | What it does | Command |
|---|---|---|
| `ducks` | 10 biggest items here, readable sizes, plus a total | `du -chs * \| sort -rh \| head -11` |
| `ds` | everything here sorted by size, biggest last | `du -ks * \| sort -n` |
| `wotgobblemem` | 15 processes using the most memory | `ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A \| sort -n -k 6 \| tail -15` |

`sort -h` (human-readable sizes) needs macOS Mojave or newer. On older macOS,
`brew install coreutils` and use `gsort -rh`.

`ducks` and `ds` skip hidden files and folders (the `*` doesn't match names starting with `.`).

## Adding your own

Machine-specific aliases (project folders, SSH shortcuts) go in `~/.aliases.local`. It's loaded
after `~/.aliases`, isn't tracked in git, and survives re-installs. See
[Local files](/dotfiles/shell/local-files/).

Ideas: [alias.sh](http://alias.sh/), [commandlinefu.com](https://www.commandlinefu.com/commands/browse/sort-by-votes).
