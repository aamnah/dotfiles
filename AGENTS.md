# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

If an `AGENTS.local.md` exists next to this file, read it too: it holds local notes that aren't part of the repo.

## Repository purpose

Personal dotfiles — shell, editor, and terminal configs intended to be deployed to `$HOME`. No build system for the configs themselves, no tests. Contributions are edits to config files, the install script, and the docs site in `docs/` (the only part with a build step — Starlight/Astro, npm).

## Layout

- Shell (bash): `.bash_profile`, `.bashrc` (non-login shim that loads `.bash_profile`), `.inputrc`
- Shell (zsh): `.zshrc`, `.zshenv`, `.zprofile`
- Shell (shared): `.aliases`, `.functions` — sourced by both bash and zsh; shell-specific bits guarded by `$ZSH_VERSION` / `$BASH_VERSION`
- Editors: `.config/nano/nanorc`, `.vimrc`, `.config/nvim/init.lua`
- Terminal / multiplexer: `.config/kitty/kitty.conf`, `.config/tmux/tmux.conf` plus `.tmux.conf` shim
- Prompt: `.config/starship.toml` (cross-shell; two-line Kali-style layout with the Lasik palette)
- Tools: `.gitconfig`, `.gitignore_global`, `.config/tmuxp/default.yaml`, `.config/peaclock/config`
- Deployment: `install.sh`
- `CHANGELOG.md` — every user-facing change, newest first, in date-versioned releases
- `docs/` — documentation site (Starlight), one page per config; deployed to GitHub Pages by `.github/workflows/docs.yml`. Screenshots live in `docs/src/assets/screenshots/`. Not installed by `install.sh`.

XDG-style configs (kitty, nvim) live under `.config/<tool>/` in the repo, mirroring their destination at `$HOME/.config/<tool>/`. New configs that follow the XDG convention should use this layout rather than a dot-prefixed file at the repo root.

`.bash_profile` and `.zshrc` both source `~/.aliases` and `~/.functions` (plus optional `.local` variants). `.bashrc` only loads `.bash_profile`, so non-login bash shells get the same setup.

## install.sh architecture

`install.sh` deploys configs to `$HOME`, adjusting paths for the detected OS/arch.

- `detect_system` runs first and sets three globals used by the install functions:
  - `SYSTEM` — one of `linux`, `macos-intel`, `macos-arm`
  - `NANO_SHARE` — the system nano syntax dir for this platform (`/usr/share/nano`, `/usr/local/share/nano`, or `/opt/homebrew/share/nano`)
  - `PKG_MGR` — one of `apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`, `brew` (macOS only), or empty if none found
- `backup_if_exists` is shared — any existing target is moved to `<dest>.bak.<timestamp>` before the new file is written.
- `as_root <cmd>...` is shared — runs a command directly when already root (Docker), else via `sudo`. Use it for any root-only step (editing `/etc`, `locale-gen`).
- Never pipe into `grep -q` (or `head`) inside `install.sh`: it runs with `set -o pipefail`, and when grep quits early the writing command gets SIGPIPE, which makes the check fail even on a match. Use `grep … >/dev/null` instead.
- `pkg_install <package>...` is shared — installs through `$PKG_MGR` via `as_root`. Returns non-zero on failure; callers warn and continue rather than abort. `ensure_<tool>` functions use it to install missing binaries; never call a package manager directly.
- One `install_<tool>` function per config file. Each function is self-contained: it checks for the source, warns if the tool is missing, backs up, then installs.

Platform-specific rewrites happen at copy time via `sed`, not by maintaining separate source files. Example: `.config/nano/nanorc` hard-codes the Linux `include "/usr/share/nano/*.nanorc"` path, and `install_nano` rewrites it to `$NANO_SHARE` during copy. When adding a new tool that has platform-specific paths, follow this pattern rather than forking the source file.

Run with `./install.sh` from the repo root, or `./install.sh --remote` to fetch configs from `raw.githubusercontent.com/aamnah/dotfiles/main` instead of the local checkout (useful for `curl … | bash -s -- --remote` on a fresh machine).

Install questions: `ask_questions` fills `SHELL_CHOICE` (zsh | bash | keep) and `LOCALE` from flags (`--shell=`, `--locale=`), prompts, or the `DEFAULT_*` globals (with `-y`, or when there's no terminal). `confirm_plan` shows the plan and asks before anything changes.

- Prompts must read from `/dev/tty`, never stdin — under `curl | bash` stdin is the script itself. Use `ask_choice` / `can_prompt` rather than a bare `read`.
- All top-level work runs inside `main`, called on the last line, so a piped script doesn't start until it has fully downloaded. Add new steps inside `main`, not at file level.
- The chosen locale is written to `~/.config/locale.conf` (`LANG=…`); `.zshenv` and `.bash_profile` read it and fall back to `C.UTF-8` if that locale isn't installed.

Source resolution is centralized in `fetch_source <repo-relative-path>`. Local mode returns `$REPO_DIR/<path>`; remote mode `curl`s into a tempdir (cleaned via `trap` on `EXIT`) and returns that path. Install functions should only ever go through `fetch_source` — never reference `$REPO_DIR` directly — so a new config works in both modes for free.

## Adding a new config

1. Add the dotfile at the repo root (dot-prefixed if it lands at `~/.<name>`).
2. Add an `install_<tool>` function in `install.sh` modeled on `install_nano` / `install_tmux`.
3. Call it inside `main` at the bottom of `install.sh` (after `confirm_plan`).
4. If the config references absolute system paths that differ across Linux / macOS Intel / macOS ARM, extend `detect_system` to set a new path global and rewrite with `sed` inside the install function.

## Notes

- Use Conventional Commits for commit messages (for example, `feat(tmux): add TPM plugin install`, `fix(shell): quote path expansion`).
- Aliases/functions in `.aliases` and `.functions` that differ between Linux (GNU) and macOS (BSD) pick the right command via `$IS_MACOS` / `$IS_LINUX` (e.g. `emptytrash`, `localip`, `flushdns`). Don't assume a command works cross-platform without checking.
- `.config/tmux/lasik.tmux` is the "Lasik" theme (matches the author's VSCode theme); `tmux.conf` currently loads `catppuccin.tmux` by default. Lasik's color palette variables are defined near the top of the file — edit those rather than the individual `set -g` lines when adjusting colors.
- The docs site (`docs/src/content/docs/`) documents every config, alias and function; `README.md` is only a short intro linking to it. When adding, renaming or removing a config, alias, function or installer behaviour, update the matching docs page (and the sidebar in `docs/astro.config.mjs` for new pages). Edge cases go on the page itself and in `reference/troubleshooting.md` / `reference/known-issues.md`.
- Add user-facing changes to `CHANGELOG.md` under today's date (`## YYYY.MM.DD`), grouped as **Added** / **Changed** / **Fixed** / **Removed** / **Theme** / **Known**, one short sentence each. Create the release if it doesn't exist yet, and add it to the "Jump to" line at the top.
- Docs links between pages must start with `/dotfiles/` (GitHub Pages sub-path). `npm run build` in `docs/` fails on broken links or anchors — run it after editing docs.
- `~` doesn't expand, use `$HOME` instead
- don't take away useful comments. when adding new code, add comments to briefly mention why it was added and, if applicable, what would happen if it is not added