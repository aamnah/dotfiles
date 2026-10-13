---
title: VS Code
description: Get shell syntax highlighting for dotfiles that have no file extension.
---

VS Code picks the language from the file extension. Dotfiles like `.aliases` have none, so they
open as plain text.

Tell VS Code they're shell scripts — add this to your user `settings.json`
(**Ctrl+Shift+P** → "Preferences: Open User Settings (JSON)"):

```json
"files.associations": {
    ".aliases": "shellscript",
    ".aliases.local": "shellscript",
    ".functions": "shellscript",
    ".functions.local": "shellscript",
    ".zshenv.local": "shellscript",
    ".zshrc.local": "shellscript",
    ".zsh_secrets": "shellscript",
    ".zsh_aliases": "shellscript",
    ".zsh_functions": "shellscript",
    "*.tmux": "shellscript",
    "*.zsh": "shellscript"
}
```

`.zshrc`, `.bashrc` and `.bash_profile` are recognised already.

`*.tmux` files aren't really shell scripts, but shell highlighting is close enough for tmux's
syntax.
