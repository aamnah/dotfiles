# Changelog

Every change to these dotfiles since the first commit in June 2014, newest first. Versions are dates (`YYYY.MM.DD`). Older years are grouped into one release each.

**Jump to:** [2026.10.13](#20261013) · [2026.09.23](#20260923) · [2026.08.26](#20260826) · [2026.05.25](#20260525) · [2026.05.21](#20260521) · [2026.05.08](#20260508) · [2026.05.05](#20260505) · [2026.04.27](#20260427) · [2026.04.25](#20260425) · [2026.04.24](#20260424) · [2026.04.14](#20260414) · [2020–2023](#20202023) · [2019](#2019) · [2018](#2018) · [2015–2016](#20152016) · [2014.08.24](#20140824) · [2014.06.21](#20140621)

---

## 2026.10.13

**October 13, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/d0f78d8...8340364)

The installer grew up. It now asks two questions (your login shell and your locale), shows a plan before touching anything, and installs what the configs need, on Ubuntu, Debian, Fedora, Arch, openSUSE and Alpine. Everything is documented on a new docs site with search and a high-contrast mode.

**Added**

- `install.sh` asks for your login shell (zsh by default, bash, or keep your current one) and runs `chsh` for you.
- `install.sh` asks for your locale (`en_US.UTF-8` by default) and generates it if it's missing. Your choice is saved to `~/.config/locale.conf`.
- `-y` skips all questions. `--shell=` and `--locale=` answer them up front. With no terminal (Docker builds, CI) the defaults are used automatically.
- The installer shows a plan and asks `Proceed? [Y/n]` before changing anything.
- On desktops the installer asks for a Nerd Font (Hasklug by default; JetBrains Mono, Fira Code, Meslo, Caskaydia Cove or Hack) and installs it for you, so prompt and tmux icons show instead of boxes. `--font=` picks one up front; kitty's config follows your choice.
- kitty's theme files (Lasik and Catppuccin Mocha) are installed with `kitty.conf`, so kitty starts with the Lasik colours.
- Missing tools are installed: zsh, `less`, `bash-completion`, `notify-send` (desktops only) and kitty's terminfo (servers, so SSH from kitty works).
- Bash support: `install.sh` installs `.bash_profile`, `.inputrc` and a small `.bashrc` that loads `.bash_profile`, so new terminal tabs get your aliases too.
- Ubuntu's useful defaults in both shells: `lesspipe` (read archives and PDFs with `less`), `dircolors`, coloured zsh completion, bash-completion and the `alert` alias.
- `~/.bash_profile.local` for machine-specific lines in bash (like `~/.zshenv.local` for zsh).
- Bash adds `~/bin` and `~/.local/bin` to `PATH`, as Ubuntu's `~/.profile` would.
- zsh completion is case-insensitive and matches anywhere in a name. `source <Tab>` only offers files in the current folder.
- Git defaults: new repos start on `main`, Windows line endings are converted on commit, and `git pull` rebases.
- A 6-pane tmuxp layout with a clock (`peaclock`) and the weather.
- A docs site with one page per config, search, troubleshooting, known issues, and Light / Dark / High contrast themes.
- The changelog is on the docs site too, with a coloured tag on every change: [Changelog](https://aamnah.github.io/dotfiles/reference/changelog/).

**Changed**

- Vim, Neovim and nano all indent with tabs, shown 4 wide (Vim used 2 spaces, nano 4 spaces). YAML files get spaces in Vim and Neovim, because YAML doesn't allow tabs.
- The installer also installs `.vimrc`, the tmuxp layout, the peaclock config and `.gitignore_global`.
- The installer adds the Git defaults and aliases to your own git settings, one at a time. Your `~/.gitconfig` isn't replaced, and settings you already have are kept.
- bash loads `~/.zsh_secrets` too, so your API keys work in both shells.
- The Android SDK is only added to `PATH` when it's installed.
- `.zshrc.local.example` is a short, up-to-date template.
- The README is now a short intro that links to the docs site.
- The "kitty not found" warning only appears on desktops. On a server kitty isn't needed.
- Remote installs use the `main` branch.
- The Claude Code alias is now `c` instead of `cc`, so the C compiler `cc` works again.
- `myip` shows all your IP addresses: the local one and the public one from both ifconfig.me and OpenDNS, with an IPv6 column when IPv6 is available. It replaces the `ip` and `localip` aliases, so Linux's own `ip` command works again.
- The local IP in `myip` and `ii` comes from the interface that actually leads to the internet, so it also works on Arch, Alpine and Macs on Ethernet.

**Fixed**

- `install.sh` failed because it looked for `.nanorc` in its old place.
- Bash printed `setlocale: cannot change locale` warnings on systems without the `en_US` locale. The shells now fall back to `C.UTF-8`.
- Installing on a fresh Arch system failed with "target not found".
- A cut-off download of `install.sh` through `curl | bash` could run half an install. Now nothing runs until the whole script has arrived.
- On Fedora the login shell was set to an odd path (`/usr/sbin/zsh`).
- Some "is it installed?" checks could wrongly answer no on systems with a lot of output (many fonts or locales).
- One failed step (for example no network while installing starship) no longer stops the whole installer. The other steps still run, and the failed ones are listed at the end.
- Vim no longer shows an error when the `sublimemonokai` colour scheme is missing. It uses a built-in one instead.
- kitty's Catppuccin theme file had a typo in its name (`catppucin`), so switching to it failed.
- The tmux comment about installing plugins now says the right key: Prefix + Shift+I.

**Theme**

- kitty (Lasik): softer tab text colours.

**Known**

- The installer hasn't been tested as a normal user with `sudo`, or on macOS since these changes.
- More on the docs site's [Known issues](https://aamnah.github.io/dotfiles/reference/known-issues/) page.

---

## 2026.09.23

**September 23, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/91719ac...d0f78d8)

**Added**

- zsh tab completion matches anywhere in a file name, and ignores case.
- `source <Tab>` only completes files in the current folder.

---

## 2026.08.26

**August 26, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/d23d29e...91719ac)

**Added**

- Inside kitty, `ssh` uses `kitty +kitten ssh`, which copies kitty's terminfo to the server so programs there work properly.

---

## 2026.05.25

**May 25, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/dcf83fe...d23d29e)

**Added**

- kitty: tmux-style splits (**Ctrl+Shift+\\** side by side, **Ctrl+Shift+-** top and bottom), opened in the current folder.
- kitty: move between splits with **Ctrl+Shift+H / J / K / L**, like Vim.

---

## 2026.05.21

**May 21, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/aae3e01...dcf83fe)

**Changed**

- The nano config moved to `.config/nano/nanorc` in the repo. It's still installed as `~/.nanorc`.

**Theme**

- kitty (Lasik): new colours for active and inactive tabs and windows.
- nano: darker status bar.
- peaclock: new colours for the active and inactive blocks.
- New screenshots of kitty and nano.

---

## 2026.05.08

**May 8, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/9b3c63e...aae3e01)

**Added**

- Neovim: sensible defaults (relative line numbers, system clipboard, rulers, split directions, a blinking cursor), each explained in a comment.
- nano: spell check with `aspell` (**Ctrl+T** twice).

---

## 2026.05.05

**May 5, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/df13bff...9b3c63e)

**Added**

- The prompt shows the hostname when you're connected over SSH.
- A global gitignore (`.gitignore_global`) for OS and editor clutter.
- An example `~/.zshrc.local` for machine-specific settings.

**Changed**

- Aliases and functions are one shared file each (`.aliases`, `.functions`), used by both bash and zsh, instead of a copy per shell.
- zsh starts faster: environment setup moved to `.zshenv`, nvm loads only when first used, and Homebrew's setup is cached.

**Removed**

- Machine-specific paths and code, so the configs work on any computer.

---

## 2026.04.27

**April 27, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/0d3d02b...df13bff)

**Added**

- tmux shows a title and number on top of each pane.

**Theme**

- kitty: Lasik and Catppuccin Mocha themes.

---

## 2026.04.25

**April 25, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/e7be737...0d3d02b)

**Added**

- A peaclock config (a big clock for the terminal).
- A tmuxp default layout, used by the new `t` function.

**Changed**

- Every alias was checked to work on both Linux and macOS, and in both bash and zsh.
- `ii` rewritten as a compact system summary with coloured usage bars for memory and disk.
- `getwebsite` and `spy` improved. `t` works in bash too.
- The tmux config is split into theme files (Lasik, Catppuccin, and a reset) and lives in `~/.config/tmux/`.

**Removed**

- kitty's audio bell.

**Theme**

- The Starship prompt uses the Lasik palette, matching the Lasik VS Code theme.

---

## 2026.04.24

**April 24, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/12f951c...e7be737)

A fresh start after a few quiet years: zsh joins bash, and there's an installer.

**Added**

- zsh configs: `.zshrc`, `.zshenv` and `.zprofile`.
- `install.sh`: copies the configs into place and backs up what it replaces. `--remote` installs straight from GitHub without cloning.
- Configs for kitty, Neovim and the Starship prompt.
- The Starship prompt in bash too.

**Changed**

- Oh My Zsh replaced by a lean zsh setup with Starship.
- Every file got the same header (description, compatibility, version, dates).
- tmux uses the Lasik theme, and the status bar is left-aligned.

**Removed**

- `.bash_colors`, `.dev`, `.yarnrc.yml` and functions nobody used any more.

---

## 2026.04.14

**April 14, 2026** · [Compare changes](https://github.com/aamnah/dotfiles/compare/616c9c2...12f951c)

**Changed**

- nano: new settings and colour definitions.

---

## 2020–2023

**July 2020 – February 2023** · [Compare changes](https://github.com/aamnah/dotfiles/compare/bd7020e...616c9c2)

**Added**

- Aliases for common folders and the SSH agent.
- Android and Genymotion folders on `PATH`.
- A Yarn config (removed again in 2026).
- Cache folders in `.gitignore`.

**Theme**

- nano: updated colours.

---

## 2019

**2019** · [Compare changes](https://github.com/aamnah/dotfiles/compare/5051c93...bd7020e)

**Added**

- A nano config, with coloured line numbers.
- Git aliases: `git lg` (a pretty history graph) and `git s` (`git status`).
- Timestamps in bash history.
- The prompt shows the git branch, and `$` is colour-coded.
- A `ydl` alias for downloading videos.

**Changed**

- `ducks` shows sizes in human-readable form.
- Updated `ls` flags and bash history settings.
- Coloured `grep` through an alias instead of the outdated `GREP_OPTIONS`.

---

## 2018

**2018** · [Compare changes](https://github.com/aamnah/dotfiles/compare/4197dd7...5051c93)

**Added**

- Configs for Vim, tmux, Git and readline (`.inputrc`: case-insensitive Tab completion).
- A `.gitignore`.

**Changed**

- `.aliases` renamed to `.bash_aliases`, and `.colors` to `.bash_colors`.
- A new default prompt, and unused items removed from `.bash_profile`.

---

## 2015–2016

**January 2015 – December 2016** · [Compare changes](https://github.com/aamnah/dotfiles/compare/4e3146a...4197dd7)

**Added**

- `getwebsite` to download a whole site for offline reading.
- `flush` and `flushdns` to clear the DNS cache.
- `bell` to ring when a command finishes (removed in 2026).
- Aliases `t` and `tf`, and `todo.txt` tweaks.
- A `.dev` file for development settings (removed in 2026).
- A screenshot of the coloured command line.

**Changed**

- Synced with the setup on the Mac.
- `authme` copies your RSA key instead of the DSA one.

---

## 2014.08.24

**August 24, 2014** · [Compare changes](https://github.com/aamnah/dotfiles/compare/92bcecf...4e3146a)

**Added**

- `ii`: useful information about the host.
- `extract`: unpack most archive types with one command (removed in 2026).
- `authme`: copy your SSH key to a server.
- Security aliases: `spy`, `sniff` and `netlisteners`.
- More aliases, many from [alias.sh](http://alias.sh), and a detailed `lsl` listing.
- Colour for `ls`, `tree` and `grep` matches, and a shared `.colors` file.
- A README explaining each file.

---

## 2014.06.21

**June 21, 2014** · [First commit](https://github.com/aamnah/dotfiles/commit/ffc05a1)

The first version, copied from a Mac.

**Added**

- `.bash_profile` with a coloured prompt: green for normal users, red for root.
- Case-insensitive globbing, appending to history, and autocorrect for typos in `cd`.
- `.aliases`, some borrowed from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles).
- `.functions` with `take`: make a folder and go into it.
