# CLAUDE.md

This file provides guidance to coding agents when working with code in this repository.

## Repository purpose

Personal dotfiles — shell, editor, and terminal configs intended to be deployed to `$HOME`. No build system, no tests. Contributions are edits to config files and the install script.

## Layout

- Shell (bash): `.bash_profile`, `.bash_aliases`, `.bash_functions`, `.inputrc`
- Shell (zsh): `.zshrc`, `.zshenv`, `.zprofile`, `.zsh_aliases`, `.zsh_functions`
- Editors: `.nanorc`, `.vimrc`, `.config/nvim/init.lua`
- Terminal / multiplexer: `.config/kitty/kitty.conf`, `.tmux.conf`
- Prompt: `.config/starship.toml` (cross-shell; port of OMZ "candy" theme)
- Misc: `.gitconfig`, `.yarnrc.yml`
- Deployment: `install.sh`
- `screenshots/` — images referenced from `README.md`

XDG-style configs (kitty, nvim) live under `.config/<tool>/` in the repo, mirroring their destination at `$HOME/.config/<tool>/`. New configs that follow the XDG convention should use this layout rather than a dot-prefixed file at the repo root.

`.bash_profile` sources `~/.bash_aliases` and `~/.bash_functions` on login (see loop at the bottom of the file).

## install.sh architecture

`install.sh` deploys configs to `$HOME`, adjusting paths for the detected OS/arch.

- `detect_system` runs first and sets two globals used by the install functions:
  - `SYSTEM` — one of `linux`, `macos-intel`, `macos-arm`
  - `NANO_SHARE` — the system nano syntax dir for this platform (`/usr/share/nano`, `/usr/local/share/nano`, or `/opt/homebrew/share/nano`)
- `backup_if_exists` is shared — any existing target is moved to `<dest>.bak.<timestamp>` before the new file is written.
- One `install_<tool>` function per config file. Each function is self-contained: it checks for the source, warns if the tool is missing, backs up, then installs.

Platform-specific rewrites happen at copy time via `sed`, not by maintaining separate source files. Example: `.nanorc` hard-codes the Linux `include "/usr/share/nano/*.nanorc"` path, and `install_nano` rewrites it to `$NANO_SHARE` during copy. When adding a new tool that has platform-specific paths, follow this pattern rather than forking the source file.

Run with `./install.sh` from the repo root, or `./install.sh --remote` to fetch configs from `raw.githubusercontent.com/aamnah/dotfiles/master` instead of the local checkout (useful for `curl … | bash -s -- --remote` on a fresh machine).

Source resolution is centralized in `fetch_source <repo-relative-path>`. Local mode returns `$REPO_DIR/<path>`; remote mode `curl`s into a tempdir (cleaned via `trap` on `EXIT`) and returns that path. Install functions should only ever go through `fetch_source` — never reference `$REPO_DIR` directly — so a new config works in both modes for free.

## Adding a new config

1. Add the dotfile at the repo root (dot-prefixed if it lands at `~/.<name>`).
2. Add an `install_<tool>` function in `install.sh` modeled on `install_nano` / `install_tmux`.
3. Call it at the bottom of `install.sh` after `detect_system`.
4. If the config references absolute system paths that differ across Linux / macOS Intel / macOS ARM, extend `detect_system` to set a new path global and rewrite with `sed` inside the install function.

## Notes

- Many aliases/functions in `.bash_aliases`, `.bash_functions`, and `.dev` are macOS-oriented (e.g. `emptytrash` targets `/Volumes/*/.Trashes`, `localip` uses `ipconfig getifaddr en0`). The README calls this out. Porting individual commands to Linux is expected and welcome, but don't assume a command works cross-platform without checking.
- `.tmux.conf` is the "Lasik" theme (matches the author's VSCode theme). Color palette variables are defined at the top of the file — edit those rather than the individual `set -g` lines when adjusting colors.
- `README.md` documents the user-facing aliases and functions. Keep it in sync when renaming or removing entries.
