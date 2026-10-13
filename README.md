## .Files

These files are an accumulation of bash and zsh aliases, shortcuts and functions that i have collected over the years — plus configs for kitty, tmux, Starship, nano and Neovim, and an installer.

Cross-platform: aliases that wrap commands with Linux/macOS differences (GNU vs BSD flags, trash paths, DNS flush, screen lock) detect the OS at source-time and pick the right invocation. Same alias name on both platforms, the right command behind it.

**Documentation: [aamnah.github.io/dotfiles](https://aamnah.github.io/dotfiles/)** — one page per config, with search, troubleshooting and known issues.

## Install

```sh
git clone https://github.com/aamnah/dotfiles && cd dotfiles && ./install.sh
```

Or without cloning:

```sh
curl -fsSL https://raw.githubusercontent.com/aamnah/dotfiles/main/install.sh | bash -s -- --remote
```

The installer asks for your login shell (zsh by default) and locale (`en_US.UTF-8` by default), shows a plan, and backs up every file it replaces. `-y` skips the questions. Details: [Install](https://aamnah.github.io/dotfiles/start/install/) · [What gets installed](https://aamnah.github.io/dotfiles/start/what-gets-installed/).

## What's inside

|              |                                                                                                                                                                                                                                                                                                         |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Shell**    | [zsh](https://aamnah.github.io/dotfiles/shell/zsh/) · [bash](https://aamnah.github.io/dotfiles/shell/bash/) · [aliases](https://aamnah.github.io/dotfiles/shell/aliases/) · [functions](https://aamnah.github.io/dotfiles/shell/functions/) · [locale](https://aamnah.github.io/dotfiles/shell/locale/) |
| **Terminal** | [kitty](https://aamnah.github.io/dotfiles/terminal/kitty/) · [tmux](https://aamnah.github.io/dotfiles/terminal/tmux/) · [Starship prompt](https://aamnah.github.io/dotfiles/terminal/starship/)                                                                                                         |
| **Editors**  | [nano](https://aamnah.github.io/dotfiles/editors/nano/) · [Vim](https://aamnah.github.io/dotfiles/editors/vim/) · [Neovim](https://aamnah.github.io/dotfiles/editors/neovim/) · [VS Code tips](https://aamnah.github.io/dotfiles/editors/vscode/)                                                       |
| **Tools**    | [Git](https://aamnah.github.io/dotfiles/tools/git/) · [tmuxp](https://aamnah.github.io/dotfiles/tools/tmuxp/) · [peaclock](https://aamnah.github.io/dotfiles/tools/peaclock/)                                                                                                                           |

Something not working? [Troubleshooting](https://aamnah.github.io/dotfiles/reference/troubleshooting/) · [Known issues](https://aamnah.github.io/dotfiles/reference/known-issues/)

## Docs site

The docs live in [`docs/`](./docs/) (Starlight). Preview locally with `cd docs && npm install && npm run dev`. See [Contributing](https://aamnah.github.io/dotfiles/reference/contributing/).

## Links

- Take a look at [Command Line Fu](http://www.commandlinefu.com/commands/browse/sort-by-votes) for some really cool commands
