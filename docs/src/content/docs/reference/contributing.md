---
title: Contributing
description: Add a config, test the installer in Docker, and work on this docs site.
---

## Adding a config

1. Add the file to the repo. Configs that live in `~/.config/<tool>/` go in `.config/<tool>/`
   in the repo; classic dotfiles go at the root (`.name`).
2. Add an `install_<tool>` function in `install.sh`, modelled on `install_kitty` or
   `install_nvim`: get the file with `fetch_source`, warn if the tool is missing, back up, copy.
3. Call it inside `main`, after `confirm_plan`.
4. If it contains paths that differ per OS, add a global in `detect_system` and rewrite with
   `sed` while copying (see [Installer internals](/dotfiles/reference/installer-internals/#platform-differences)).
5. Add a page for it in `docs/src/content/docs/` and to the sidebar in `docs/astro.config.mjs`,
   and update [What gets installed](/dotfiles/start/what-gets-installed/).

## Conventions

- **Commit messages:** [Conventional Commits](https://www.conventionalcommits.org/) —
  `feat(tmux): add plugin`, `fix(install): …`, `docs: …`.
- **Use `$HOME`, not `~`,** in scripts. `~` isn't expanded inside quotes or in many other places.
- **Comment the why.** New code says briefly why it exists and what would break without it.
  Don't remove existing explanatory comments.
- **Both shells.** Anything in `.aliases` / `.functions` must work in bash *and* zsh — guard
  shell-specific code with `$ZSH_VERSION` / `$BASH_VERSION`.
- **Both systems.** Check GNU (Linux) vs. BSD (macOS) differences; pick with `$IS_MACOS`.

## Testing the installer

Docker gives a clean system in seconds. From the repo root:

```sh
# Non-interactive run, twice — the second run should install nothing
docker run --rm -v "$PWD":/d:ro ubuntu:26.04 bash -c \
  'cp -r /d /tmp/d && cd /tmp/d && ./install.sh -y && ./install.sh -y'

# The real curl | bash path, with answers typed in through a fake terminal
printf '2\n3\nja_JP\n\n' | docker run --rm -i -v "$PWD":/d:ro debian:stable-slim bash -c \
  'cp -r /d /tmp/d && cd /tmp/d && script -qec "cat install.sh | bash" /dev/null'
```

- `-v "$PWD":/d:ro` mounts the repo read-only; the script copies it so the original can't change.
- `script -qec "…" /dev/null` runs the command inside a pretend terminal, so the installer
  thinks a person is typing; the `printf` text becomes the keypresses.

Images used for testing: `ubuntu:26.04`, `debian:stable-slim`, `fedora:latest`,
`archlinux:latest`, `opensuse/tumbleweed`, `alpine:3.20`.

## Working on the docs

The site is built with [Starlight](https://starlight.astro.build) (on Astro) and lives in
`docs/`. It needs Node.js 22.12 or newer.

```sh
cd docs
npm install          # once
npm run dev          # live preview at http://localhost:4321/dotfiles/
npm run build        # production build into docs/dist/, including the search index
```

- Pages are Markdown in `docs/src/content/docs/`. Use `.mdx` when you need components like
  tabs or cards.
- **Links between pages must start with `/dotfiles/`** — the site is served from that
  sub-path on GitHub Pages.
- Images go in `docs/src/assets/` and are linked relatively.
- **Theme modes:** `src/components/ThemeProvider.astro` and `ThemeSelect.astro` replace
  Starlight's versions to add high contrast; the colours are in `src/styles/theme.css`.
- **Text size:** the A− / A+ buttons are `src/components/TextSize.astro`, shown inside
  `ThemeSelect.astro`. The size is stored and applied in `ThemeProvider.astro`, and
  `src/styles/theme.css` scales Starlight's `--sl-text-*` sizes by it. Only text grows, not the
  column widths, so the layout keeps working at 150%.
- Search (Pagefind) only works in a **build** (`npm run build && npm run preview`), not in
  `npm run dev`.

### Screenshots

The terminal screenshots (peaclock, Vim, Neovim, `git lg`) are made by
`docs/scripts/shot.py`. It runs a program in a virtual terminal and draws the screen with the
Lasik colours and Hasklug Nerd Font, so every screenshot looks the same and none depend on your
own terminal setup.

Needs: [uv](https://docs.astral.sh/uv/), headless Google Chrome and the Hasklug Nerd Font
(the installer adds it on desktops). `uv run --with pyte --with pillow` fetches the two Python
libraries for that one run, without installing them.

**Keep personal details out.** Programs run with a throwaway home folder (`HOME=$(mktemp -d)`)
holding only the repo's configs, so no history, hostname or username shows. Look at every
image before committing it: once pushed, it's public.

Run from the repo root. Each command overwrites the image on the docs site:

```sh
S="uv run --with pyte --with pillow python3 docs/scripts/shot.py"
IMG=docs/src/assets/screenshots

# peaclock, with the repo's config in a temporary folder (peaclock writes files next to it)
P=$(mktemp -d) && cp .config/peaclock/config "$P/"
$S $IMG/peaclock.png 70 18 3 -- peaclock --config-dir "$P"

# Vim and Neovim: a throwaway home with only the repo's configs, opened at run_step() in install.sh
H=$(mktemp -d) && mkdir -p "$H/.vim/colors" "$H/.config/nvim"
cp .vimrc "$H/" && cp .vim/colors/sublimemonokai.vim "$H/.vim/colors/" && cp .config/nvim/init.lua "$H/.config/nvim/"
L=$(( $(grep -n '^run_step()' install.sh | cut -d: -f1) - 12 ))
HOME=$H $S $IMG/vim-monokai.png 100 28 3.5 --keys "2.5:\x0c" -- vim -n "+set t_ut=" "+$L" "+normal zt" install.sh
HOME=$H XDG_CONFIG_HOME=$H/.config XDG_DATA_HOME=$H/.local/share XDG_STATE_HOME=$H/.local/state \
  $S $IMG/neovim.png 100 28 3.5 --keys "2.5:\x0c" -- nvim -n "+$L" "+normal zt" install.sh

# git lg, using only the repo's .gitconfig
GIT_CONFIG_GLOBAL=$PWD/.gitconfig $S $IMG/git-lg.png 150 17 2 -- git -c color.ui=always --no-pager lg -n 17
```

- `--keys "2.5:\x0c"` presses Ctrl+L after 2.5 seconds, a redraw, so the picture is clean.
- `"+set t_ut="` makes Vim paint every cell itself. Without it, the virtual terminal leaves
  gaps in Monokai's grey background.
- `HOME=$(mktemp -d)` uses a new empty folder as the home folder for that one command.
- `vim -n` / `nvim -n`: no swap file. The editor is stopped, not closed, after the picture, so it would leave a `.install.sh.swp` behind.

`docs/scripts/tmux_preview.py` draws two tmux themes side by side (each in its own throwaway
tmux server), for comparing theme changes. Its status bar shows the machine's hostname, so it's
for previews, not for the docs.
