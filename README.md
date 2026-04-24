## .Files

These files are an accumulation of bash aliases, shortcuts and functions that i have collected over the years.

While these are Mac specific (for example, the LSCOLORS is different as compared to the GNU LS_COLORS), they can easily be ported for use on Linux.


## Shell

The repo supports both **bash** and **zsh** with feature parity in mind — pick whichever shell you prefer on a given machine. Both sets of startup files are tracked, and `install.sh` deploys both regardless of which shell is currently active, so switching shells on a box doesn't require re-running anything.

zsh is the default shell on **macOS** (since Catalina, 2019) and **Kali Linux**. On most other systems — **Ubuntu**, **Debian**, **Fedora**, **Arch**, **Alpine**, and the standard Docker base images — bash (or `sh`) is the default and zsh has to be installed explicitly:

```sh
# Debian/Ubuntu
sudo apt install zsh
# Fedora/RHEL: sudo dnf install zsh
# Arch:        sudo pacman -S zsh
# Alpine:      sudo apk add zsh

# Set as login shell (takes effect on next login)
chsh -s "$(which zsh)" "$USER"
```

`install.sh` does not run `chsh` for you — switching login shells is an explicit opt-in.

### Startup files

| zsh | runs when | bash equivalent | what to put here |
|---|---|---|---|
| `.zshenv` | **every** zsh invocation — interactive, login, scripts, cron, GUI launches | (no real equivalent) | `PATH` and env vars that everything needs to see |
| `.zprofile` | login shells only, **before** `.zshrc` | `.bash_profile` | login-once setup (e.g. `ssh-agent` autostart, tmux auto-attach) |
| `.zshrc` | interactive shells (every new tab) | `.bashrc` | aliases, functions, prompt, completion, keybindings |
| `.zlogin` | login shells, **after** `.zshrc` | (`.bash_login`, rare) | login-once setup that needs the shell already configured |
| `.zlogout` | on logout from a login shell | `.bash_logout` | cleanup on exit |

In practice most personal config can live in `.zshrc` without issue. The split matters when:

- **Something must run only once per session** — the canonical example is `ssh-agent`. Put it in `.zshrc` and every new terminal tab spawns a fresh agent; put it in `.zprofile` and every tab/subshell inherits the same `SSH_AUTH_SOCK`.
- **Something must be visible to non-interactive contexts** — cron jobs, GUI-launched apps, and scripts only source `.zshenv`. PATH belongs there for that reason.

bash collapses this distinction more aggressively: `.bash_profile` is the login file, `.bashrc` the interactive file, and many setups source the latter from the former so the same content runs in both contexts. There's no `.bash_env` analog — bash has nothing that runs for every invocation including scripts.


## Config files

`.nanorc`

Default nano:
![Default config](./screenshots/nanorc-default.png)

Custom config:
![Custom config](./screenshots/nanorc-custom.png)

### zshell

- `.zshenv` — runs for every zsh invocation (login, interactive, script). `PATH` belongs here. 
- `.zprofile` — login shells only (like `.bash_profile`).    
- `.zshrc` — interactive shells only (like `.bashrc`). 
- `.zlogin` — login, after `.zshrc`. 
- `.zlogout` — on logout.   



.bash_aliases
---
Shortcuts for directories, programs, system processes and commands.

#### Directories
- `desk` go to Desktop
- `dl` go to Downloads
- `proj` go to the folder where all projects are (variable)
- `sites` go to the folder where all sites are (variable)

#### Commands and tools
- `ydl` shortcut for `youtube-dl`
- `gath` starts ssh-agent and loads SSH key (variable). used for Git purposes

#### Misc.
- `emptytrash` Empty the Trash on all mounted volumes and the main HDD
- `cleanup` Recursively delete _.DS_Store_ files
- `chromekill` Kill all the tabs in Chrome to free up memory
- `afk` Lock the screen (when going AFK)
- `reload` Reload the shell (i.e. invoke as a login shell)
- `tree` Always list the tree command in color coding

#### Smart Listings
- `ll` List all (-a) files and directories in a detailed (-l), human readable (-h), color coded (-G) way with a trailing slash (-F).
- `lsd` Only list directories, including hidden ones

#### Sudo
- `dang` repeat the last command with sudo, basically `sudo !!` equivalent

#### Disk Usage
- `ducks` List top ten largest files/directories in current directory
- `ds` Find the biggest in a folder

#### Memory
- `wotgobblemem` What's gobbling the memory?

#### DNS
- `flush`, `flushdns` Flush DNS cache
- `dig` Better and more to-the-point dig results

#### IPs
- `ip`, `myip` Show Public IP address
- `localip` Show local IP

#### Security
- `netlisteners` Show active network listeners



### bash

.bash_profile

- `PS1` - Prompt shows only current working directory `\w` and `\$`. Newline at both beginning and end makes differentiating command output easier
- Prompt uses [starship](https://starship.rs) when available, falling back to the manual git-aware `PS1` on minimal boxes (VPS, Docker images) where starship isn't installed.

### custom prompt with Starship

Cross-shell prompt configured by `.config/starship.toml`. Same config drives bash and zsh, so the prompt looks identical in both. The included config is a port of the OMZ "candy" theme:

    user@host [HH:MM:SS] [~/path] [branch] *
    -> %

`install.sh` installs the starship binary if it's missing — `brew install starship` on macOS, the official installer (`curl -sS https://starship.rs/install.sh | sh`) elsewhere — then drops `starship.toml` into `~/.config/`. To install manually:

```sh
# binary
curl -sS https://starship.rs/install.sh | sh

# activate (one line per shell rc)
echo 'eval "$(starship init bash)"' >> ~/.bash_profile
echo 'eval "$(starship init zsh)"'  >> ~/.zshrc
```

## .bash_functions

- `take()` create a dir and cd to it by taking a name
- `extract()` Extract most know archives with one command
- `ii()` display useful host related informaton
- `getwebsite()` wget a whole website
- `spy()` identify and search for active network connections
- `sniff()` sniff GET and POST traffic over http v2
- `bell()` Ring the system bell after finishing a script/compile

## .dev

- `gplv3` Add a GPL license file to your project

## Resources

- Take a look at [Command Line Fu](http://www.commandlinefu.com/commands/browse/sort-by-votes) for some really cool commands
