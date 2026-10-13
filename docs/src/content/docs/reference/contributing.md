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
