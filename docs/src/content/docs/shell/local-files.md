---
title: Local files & secrets
description: Keep machine-specific settings and API keys out of the repo with .local files and ~/.zsh_secrets.
---

Some settings only belong on one machine: a project folder shortcut, a work proxy, a Java path,
an API key. Put those in **local files**. They're loaded automatically if they exist, never
committed, and never touched by the installer.

## Which file for what

| File | Loaded by | Use it for |
|---|---|---|
| `~/.aliases.local` | bash + zsh | your own aliases |
| `~/.functions.local` | bash + zsh | your own functions |
| `~/.zshrc.local` | zsh, interactive | zsh-only prompt/completion tweaks |
| `~/.zshenv.local` | every zsh | machine-specific `PATH` and environment variables |
| `~/.bash_profile.local` | every bash (login and new tabs) | the same for bash. Loaded last, so it can override anything |
| `~/.zsh_secrets` | every zsh | API keys and tokens |

Each one is loaded **after** the shared file, so it can override anything — including removing
an alias you don't want:

```sh
# ~/.aliases.local
unalias kkk       # drop an alias you don't want
alias proj='cd ~/work/big-project'
```

### Installers edit `~/.zshrc` and `~/.bashrc`: move their lines

Many tools' installers (deno, microsandbox, opencode…) append a `PATH` line to `~/.zshrc`,
`~/.bashrc` or `~/.profile`. The dotfiles installer **replaces** `~/.zshrc` and `~/.bashrc`
(keeping a backup), so those lines would stop working. Move them to `~/.zshenv.local` (zsh)
and `~/.bash_profile.local` (bash).

### `PATH` goes in `.zshenv.local`, not `.zshrc.local`

`.zshrc.local` only loads for interactive shells. A cron job, a script, or
`ssh host 'mycommand'` wouldn't see a `PATH` set there. `.zshenv.local` loads for every zsh.

## Secrets

Keep live keys in `~/.zsh_secrets` and lock the file so only you can read it:

```sh
touch ~/.zsh_secrets && chmod 600 ~/.zsh_secrets
echo 'export OPENAI_API_KEY="sk-…"' >> ~/.zsh_secrets
```

`chmod 600` means: the owner can read and write, nobody else can do anything.

:::caution
`~/.zsh_secrets` is only read by **zsh**. In bash, put secrets in `~/.functions.local` or
`~/.aliases.local` (with the same `chmod 600`), or source the secrets file from there:
`[ -f "$HOME/.zsh_secrets" ] && . "$HOME/.zsh_secrets"`.
:::

## The example file

`.zshrc.local.example` in the repo is an older template (Homebrew and nvm setup). Both of those
now live in `.zshenv` — you don't need to copy them. Use it as a reference for the file's shape.

## Old file names

`.zshrc` still loads `~/.zsh_aliases`, `~/.zsh_functions` and their `.local` versions if they
exist, from before the shared `.aliases` / `.functions` files. bash doesn't load the
`.bash_aliases` name.
