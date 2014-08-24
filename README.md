.Files
========

These files are an accumulation of bash aliases, shortcuts and functions that i have collected over the years. 

While these are Mac specific (for example, the LSCOLORS is different as compared to the GNU LS_COLORS), they can easily be ported for use on Linux.

.bash_profile
---

####Colors
Six basic colors (blue, cyan, green, magenta, red, yellow) have been set in `.bash_profile` for easy use. You can use these anywhere in the terminal by wrapping the code in appropriate color tags. There is an opening tag in the format of `$color_name` and a closing tag `$color_off` at the end. For example:

`echo -e "\n${color_cyan}Current date :$color_off " ; date` 

will echo `Current date :` in cyan color and then output `date` on the next line.

.aliases
---
Shortcuts for directories, programs, system processes and commands.

.functions
---
- `take ()` create a dir and cd to it by taking a name
- `extract ()` Extract most know archives with one command
- `ii ()` display useful host related informaton

.colors
---
This file has ANSI color codes saved into human readable variables. The variable names and codes have been taken from [here](https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash) and have been kept the same for universal recognition.

While `.bash_profile` has six color variables added, `.colors` is a more elaborate version with eight colors and their bold, underlined, background, high intensity, bold high intensity and high intensity version.

####Usage:
Wrap the code you want to color in the appropriate tags. There is an opening tag in the format of `$Name` and a closing tag `$Color_Off` at the end.  For example

`echo -e "\n${Yellow}Current date :$Color_Off " ; date`

will echo `Current date :` in yellow color and then output `date` on the next line.
