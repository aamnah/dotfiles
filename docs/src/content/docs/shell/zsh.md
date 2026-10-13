---
title: zsh
description: What .zshenv, .zprofile and .zshrc set up — options, history, completion, Homebrew, nvm lazy-loading, prompt.
---

Three files, each with a different job. See [Shell overview](/dotfiles/shell/overview/#which-file-loads-when)
for when each one runs.

## `.zshenv` — every zsh

Runs for **every** zsh, including scripts and cron jobs, so it only holds things those need —
and nothing that prints output or is slow.

| What | Details |
|---|---|
| OS detection | sets `IS_MACOS` or `IS_LINUX` (see [overview](/dotfiles/shell/overview/#detecting-linux-vs-macos)) |
| Locale | `LANG` / `LC_ALL` from `~/.config/locale.conf`, falling back to `C.UTF-8` — see [Locale](/dotfiles/shell/locale/) |
| `DOTNET_CLI_TELEMETRY_OPTOUT=true` | turns off .NET telemetry |
| `~/.zsh_secrets` | loaded if it exists — API keys etc. See [Local files](/dotfiles/shell/local-files/#secrets) |
| `~/.zshenv.local` | loaded if it exists — machine-specific `PATH` |
| Homebrew | sets `PATH` for brew packages (Linux, Apple Silicon or Intel locations) |
| nvm | sets `NVM_DIR` and puts your default Node version on `PATH` |

### Homebrew, cached

`brew shellenv` prints the `PATH` settings Homebrew needs. Running it takes 20–40 ms, on every
shell start. `.zshenv` saves its output to `~/.cache/brew_shellenv` and only re-runs it when the
`brew` program is newer than the saved copy (i.e. after a Homebrew update).

If brew's paths ever look wrong, delete the cache and open a new shell:

```sh
rm ~/.cache/brew_shellenv
```

### Node without loading nvm

Loading nvm (`nvm.sh`) takes 150–300 ms. `.zshenv` instead reads nvm's `default` alias (following
chains like `default → lts/iron → 20.18.0`) and puts that version's `bin` folder on `PATH`.
Scripts and cron get a working `node` instantly; nvm itself only loads when you use it (see
`.zshrc` below).

## `.zprofile` — login shells

Currently empty. It's the place for once-per-login things like starting `ssh-agent` or
auto-attaching to tmux.

## `.zshrc` — interactive shells

### Options

| Option | What it does |
|---|---|
| `AUTO_CD` | type a folder name (or `..`) to `cd` into it |
| `AUTO_PUSHD` | every `cd` remembers the previous folder — `popd` goes back |
| `PUSHD_IGNORE_DUPS` | don't remember the same folder twice |
| `EXTENDED_HISTORY` | save when each command ran and how long it took |
| `SHARE_HISTORY` | all open shells share one history |
| `HIST_IGNORE_ALL_DUPS` | drop older duplicates when a command repeats |
| `HIST_IGNORE_SPACE` | a command starting with a space isn't saved (useful for secrets) |
| `HIST_REDUCE_BLANKS` | tidy extra spaces before saving |

History: `~/.zsh_history`, 50,000 commands. (zsh saves **nothing** by default — `SAVEHIST` is 0.)

### Completion

Tab completion (`compinit`) checks its cache file `~/.zcompdump` fully once a day and skips the
check otherwise — saving 50–100 ms per shell start.

Matching is forgiving, tried in this order:

1. what you typed, completed as usual
2. **anywhere in the name**: `conf<Tab>` finds `kitty.conf`
3. **any case**: `doc<Tab>` finds `Documents`

`source <Tab>` only offers files in the current folder. zsh's default would also list every
command on `PATH`, which is never what you want to source.

If completion acts strangely after installing new tools, rebuild the cache:

```sh
rm ~/.zcompdump && exec zsh
```

### nvm stubs

`nvm`, `node`, `npm` and `npx` are defined as tiny functions. The first time you run any of them,
they remove themselves, load nvm, and run your command. After that the real commands are used.

:::note
The stubs only exist in interactive shells. In scripts, `node` is the real program on `PATH`
(set up by `.zshenv`). If a tool reports `npm: command not found` from a non-interactive zsh,
check that nvm has a `default` alias: `nvm alias default 22`.
:::

### Also in `.zshrc`

- [`lesspipe`, `dircolors` and coloured completion](/dotfiles/shell/colours/)
- Loads `.aliases`, `.functions`, their `.local` versions, and `~/.zshrc.local` — see
  [Local files](/dotfiles/shell/local-files/)
- `DISABLE_AUTO_TITLE=true` so [tmuxp](/dotfiles/tools/tmuxp/) can name its windows
- The [Starship](/dotfiles/terminal/starship/) prompt, if starship is installed
