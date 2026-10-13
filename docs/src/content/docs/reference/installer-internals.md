---
title: Installer internals
description: How install.sh is built — the run order, shared helpers, globals, and the design rules behind them.
---

`install.sh` is one bash script, written to run on bash 3.2 (macOS) and up, under
`set -euo pipefail`:

- `-e` stop at the first command that fails (unless the failure is handled)
- `-u` treat unset variables as errors (catches typos)
- `-o pipefail` a pipeline fails if *any* part fails, not just the last

## Run order

Everything runs inside `main`, which is called on the very last line:

```
main
├── detect_system        SYSTEM, NANO_SHARE, PKG_MGR
├── ask_questions        SHELL_CHOICE, LOCALE  (flags → prompts → defaults)
├── confirm_plan         print plan, "Proceed? [Y/n]"
├── install_nano
├── install_tmux         + TPM, Catppuccin (git clone)
├── install_kitty        + theme files, ensure_kitty_terminfo
├── install_nvim
├── install_starship
├── ensure_shell_tools   less, bash-completion, notify-send
├── ensure_locale
├── write_locale_conf
├── ensure_zsh           only if SHELL_CHOICE = zsh
├── install_shell_common .aliases, .functions
├── install_zsh          .zshrc, .zshenv, .zprofile
├── install_bash         .bash_profile, .bashrc, .inputrc
└── set_login_shell      chsh
```

**Why `main`?** With `curl … | bash`, bash runs the script *while it's still downloading*.
Because only function definitions come before the last line, nothing runs until the whole file
has arrived. A cut-off download can't run half an install, and no command (like `apt`) can
swallow the rest of the script by reading from stdin.

## Globals

| Variable | Set by | Values |
|---|---|---|
| `SYSTEM` | `detect_system` | `linux`, `macos-intel`, `macos-arm` |
| `NANO_SHARE` | `detect_system` | nano's syntax folder for this platform |
| `PKG_MGR` | `detect_system` | `apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`, `brew`, or empty |
| `MODE` | flags | `local` or `remote` |
| `SHELL_CHOICE` | flags / `ask_questions` | `zsh`, `bash`, `keep` |
| `LOCALE` | flags / `ask_questions` | e.g. `en_US.UTF-8` |
| `ASSUME_YES` | `-y` | `0` / `1` |
| `DEFAULT_SHELL`, `DEFAULT_LOCALE` | top of file | defaults for `-y` and no-terminal runs |

On macOS only `brew` counts as a package manager; on Linux a Linuxbrew install is ignored so
system packages go through the distro's own manager.

## Shared helpers

| Helper | Job | Rule |
|---|---|---|
| `fetch_source <path>` | returns a local path for a repo file — the checkout in local mode, a downloaded temp copy in remote mode | **never** use `$REPO_DIR` directly, so every config works in both modes |
| `backup_if_exists <dest>` | moves an existing file to `<dest>.bak.<timestamp>` | call before every write |
| `install_home_files <files…>` | copy + back up a list of files to the same path under `$HOME` | used by the shell installers |
| `as_root <cmd…>` | runs a command directly when root, via `sudo` otherwise | use for anything touching `/etc` |
| `pkg_install <pkgs…>` | installs through `$PKG_MGR`; `apt-get update` once per run; `pacman -Syu` only on unsynced systems | **never** call a package manager directly; returns non-zero instead of exiting |
| `has_tty` | can we open `/dev/tty`? | |
| `can_prompt` | not `-y` **and** `has_tty` | check before asking anything |
| `ask_choice "<q>" <default> <opts…>` | numbered menu, result in `REPLY_CHOICE` | the only way to prompt |
| `normalize_locale` | `ja_JP` / `ja_JP.utf8` → `ja_JP.UTF-8`, or fail | |
| `is_desktop` | macOS, or `$DISPLAY` / `$WAYLAND_DISPLAY` set | gate desktop-only things |

### Why prompts read from `/dev/tty`

With `curl … | bash`, the script itself arrives on **stdin**. A plain `read` would take the next
line of the *script* as the answer. `/dev/tty` is the keyboard directly.

Checking that `/dev/tty` exists isn't enough: in Docker it exists but can't be opened. So
`has_tty` actually opens it:

```sh
has_tty() {
    { : </dev/tty; } 2>/dev/null     # ':' does nothing; this only tests the open
}
```

### Why failures warn instead of exit

Under `set -e` any failing command stops the script. Package installs and other optional steps
use `pkg_install … || echo "warning: …"` so a missing package never prevents the config files
from being installed. (A few older steps don't do this yet — see
[Known issues](/dotfiles/reference/known-issues/).)

## Platform differences

Paths that differ between systems are rewritten **while copying**, not kept as separate files.
Example: `nanorc` contains the Linux path `/usr/share/nano`; `install_nano` swaps in
`$NANO_SHARE` with `sed`. Add a new global in `detect_system` for any new platform-specific path.

## Package names by system

| Purpose | apt | dnf / yum | pacman | zypper | apk |
|---|---|---|---|---|---|
| notify-send | `libnotify-bin` | `libnotify` | `libnotify` | `libnotify-tools` | `libnotify` |
| kitty terminfo | `kitty-terminfo` | `kitty-terminfo` | `kitty-terminfo` | `kitty-terminfo` | `kitty-terminfo` |
| locales | `locales` + `locale-gen` | `glibc-langpack-<lang>` | `locale-gen` | `glibc-locale` | — |
| chsh | (built in) | `util-linux-user` | (built in) | (built in) | `shadow` |
