---
title: bash
description: .bash_profile holds the config, .bashrc points to it, .inputrc tunes Tab completion.
---

## `.bash_profile` — all the config

bash reads `.bash_profile` for **login** shells. Everything lives here: prompt, history, options,
locale, colours, aliases, completion.

### Prompt

If [Starship](/dotfiles/terminal/starship/) is installed, it's used — same prompt as zsh.

Otherwise a simple fallback prompt is used (handy on minimal servers):

```
~/projects/dotfiles (main) $
```

- Current folder in blue, git branch in yellow.
- `$` is green for normal users, **red for root** — a reminder you have full power.
- Blank lines above and below make it easy to see where command output starts and ends.

### History

| Setting | Effect |
|---|---|
| `HISTTIMEFORMAT="%c "` | `history` shows when each command ran |
| `HISTCONTROL=ignoreboth` | skip duplicates and commands starting with a space |
| `HISTSIZE=1000`, `HISTFILESIZE=2000` | commands kept in memory / on disk |
| `histappend` | add to the history file instead of overwriting it |

### Options (`shopt`)

| Option | Effect |
|---|---|
| `nocaseglob` | `*.JPG` also matches `photo.jpg` |
| `cdspell` | fixes small typos in `cd` paths (`cd /ect` → `/etc`) |
| `checkwinsize` | keeps `$LINES` / `$COLUMNS` right after resizing the window |

### Also in `.bash_profile`

- [Locale](/dotfiles/shell/locale/) — same logic as zsh
- `CLICOLOR=1` — coloured `ls` on macOS
- [`lesspipe` and `dircolors`](/dotfiles/shell/colours/)
- Loads `~/.aliases`, `~/.aliases.local`, `~/.functions`, `~/.functions.local`
- **bash-completion** — Tab-completes `git` branches, `apt` packages, `ssh` hosts and more.
  Needs the `bash-completion` package (the installer adds it on Linux).
- `~/bin` and `~/.local/bin` added to `PATH` if they exist. Ubuntu does this in `~/.profile`,
  but bash stops reading `~/.profile` once `~/.bash_profile` exists.
- Android SDK folders added to `PATH` (`$HOME/Android/Sdk/…`), only when that folder exists.
- `~/.zsh_secrets` loaded, so bash gets your API keys too. See [Local files](/dotfiles/shell/local-files/#secrets).
- **`~/.bash_profile.local`**, loaded last, for machine-specific lines — see
  [Local files](/dotfiles/shell/local-files/).

## `.bashrc`

`.bashrc` just points to `.bash_profile`. Why it's needed: new terminal tabs on Linux and `docker exec … bash` are **non-login** shells. They read
`~/.bashrc`, not `~/.bash_profile`. Without a `.bashrc` they'd get no aliases or prompt.

This repo's `.bashrc` does two things:

```sh
[[ $- != *i* ]] && return                              # 1. stop if not interactive
[ -f "$HOME/.bash_profile" ] && . "$HOME/.bash_profile" # 2. load the real config
```

1. **`$-` holds the shell's option letters; `i` means interactive.** bash also reads `.bashrc`
   for commands run over SSH — including `scp` and `rsync`. If the profile printed anything
   there, it would corrupt the file transfer. So non-interactive shells stop immediately.
2. Interactive shells load `.bash_profile`.

There's no double-loading: login shells read `.bash_profile` and skip `.bashrc` (as long as
`.bash_profile` never loads `.bashrc`).

:::caution[Your old `.bashrc` is replaced]
Ubuntu's default `~/.bashrc` sets up a few things. The ones that matter are ported into
`.bash_profile` (see [Colours & Ubuntu defaults](/dotfiles/shell/colours/)), but anything you
added to your own `.bashrc` is only in the backup, `~/.bashrc.bak.<timestamp>`. Move what you
need into `~/.aliases.local` or `~/.functions.local`.
:::

## `.inputrc` — Tab completion behaviour

`.inputrc` configures **readline**, the library bash uses for editing the command line. (Other
programs using readline — `python`, `psql` — pick it up too.)

| Setting | Effect |
|---|---|
| `completion-ignore-case on` | Tab completes `doc` → `Documents` |
| `show-all-if-ambiguous on` | show all matches on the first Tab, not the second |
