.Files
========

These files are an accumulation of bash aliases, shortcuts and functions that i have collected over the years.

While these are Mac specific (for example, the LSCOLORS is different as compared to the GNU LS_COLORS), they can easily be ported for use on Linux.

.bash_profile
---

####Colors
Six basic colors (blue, cyan, green, magenta, red, yellow) have been set in `.bash_profile` for easy use. You can use these anywhere in the terminal by wrapping the code in appropriate color tags. There is an opening tag in the format of `$color_name` and a closing tag `$color_off` at the end. For example:

`echo -e "\n${color_cyan}Current date :$color_off " ; date`

will echo `Current date :` in cyan color and then output `date` in
default color on the next line.

.functions
---
- `take ()` create a dir and cd to it by taking a name
- `extract ()` Extract most know archives with one command
- `ii ()` display useful host related informaton
- `getwebsite()` wget a whole website
- `spy()` identify and search for active network connections
- `sniff()` sniff GET and POST traffic over http v2

.aliases
---
Shortcuts for directories, programs, system processes and commands.

#### Directories
- `desk` go to Desktop
- `dl` go to Downloads
- `sandbox` go to ~/Sandbox
- `tmp` go to ~/Temp

#### Installs
- `agi` Apt-Get Install -y
- `update` Apt-Get Update
- `upgrade` Apt-Get Update+Upgrade+Clean

#### Misc.
- `slt` open file with Sublime Text
- `emptytrash` Empty the Trash on all mounted volumes and the main HDD
- `cleanup` Recursively delete _.DS_Store_ files
- `chromekill` Kill all the tabs in Chrome to free up memory
- `afk` Lock the screen (when going AFK)
- `reload` Reload the shell (i.e. invoke as a login shell)
- `tree` Always list the tree command in color coding

#### Smart Listings
- `lsl` List all (-a) files and directories in a detailed (-l), human readable (-h), color coded (-G) way.
- `lf` Only list directories
- `lsd` Only list directories, including hidden ones

#### Sudo
- `fuck`, `dang`, `please`, `pls` repeat the last command with sudo, basically `sudo !!` equivalents

#### Disk Usage
- `ducks` List top ten largest files/directories in current directory
- `ds` Find the biggest in a folder

#### Memory
- `wotgobblemem` What's gobbling the memory?

#### DNS
- `flush`, `flushdns` Flush DNS cache

#### IPs
- `ip`, `myip` Show Public IP address
- `localip` Show local IP
- `ips`

#### Security
- `netlisteners` Show active network listeners

.colors
---
This file has ANSI color codes saved into human readable variables. The
variable names and codes have been taken from
[here](https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash)
and have been kept the same for universal recognition.

While `.bash_profile` has six color variables added, `.colors` is a more
elaborate version with eight colors and their bold, underlined,
background, high intensity, bold high intensity and high intensity
background versions.

#### Usage:
Wrap the code you want to color in the appropriate tags. There is an
opening tag in the format of `$Name` and a closing tag `$Color_Off` at
the end.  For example

`echo -e "\n${Yellow}Current date :$Color_Off " ; date`

will echo `Current date :` in yellow color and then output `date` in
default color on the next line.

Resources
---
- Take a look at [http://alias.sh/](http://alias.sh/) for some really cool aliases
