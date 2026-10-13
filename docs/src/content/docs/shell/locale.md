---
title: Locale
description: How the locale is chosen, stored in ~/.config/locale.conf, installed, and what happens when it's missing.
---

The **locale** sets the language for program messages and the formats for dates, numbers,
money and sorting. For example `en_US.UTF-8` means English, United States formats, UTF-8 text.

| Locale | `date +%A` | Number |
|---|---|---|
| `en_US.UTF-8` | Tuesday | 1,234.5 |
| `fi_FI.UTF-8` | tiistai | 1 234,5 |
| `ja_JP.UTF-8` | 火曜日 | 1,234.5 |
| `C.UTF-8` | Tuesday | 1234.5 |

## How it's set

1. The installer asks for a locale (default `en_US.UTF-8`) — or use `--locale=…`.
2. It makes sure the locale exists on the system, generating or installing it if needed.
3. It saves your choice in **`~/.config/locale.conf`**:

   ```
   LANG=fi_FI.UTF-8
   ```

4. Every shell start, `.zshenv` (zsh) and `.bash_profile` (bash) read that file and set `LANG`
   and `LC_ALL`.

Change your mind later? Edit `~/.config/locale.conf` and open a new shell — or re-run the
installer with `--locale=…` to also install it.

No `locale.conf`? The shells use `en_US.UTF-8`.

## When the locale isn't installed

The shells first check `locale -a` (the list of installed locales). If your locale isn't there,
they use **`C.UTF-8`** instead.

Why: forcing a locale that doesn't exist makes bash print
`setlocale: cannot change locale` on **every** start, and Perl, Python and others print
"Setting locale failed" on every run. `C.UTF-8` exists almost everywhere, keeps UTF-8 (emoji,
accents) working, and shows plain-English messages.

The check costs about 1–2 ms per shell start.

## How the installer adds a locale

| System | What it does |
|---|---|
| Ubuntu, Debian | installs `locales`, enables the line in `/etc/locale.gen`, runs `locale-gen` |
| Arch | enables the line in `/etc/locale.gen`, runs `locale-gen` |
| Fedora, RHEL | installs a language pack, e.g. `glibc-langpack-en` for `en_*` |
| openSUSE | installs `glibc-locale` (all locales in one package) |
| Alpine | nothing — musl doesn't use compiled locales |
| macOS | nothing — every locale is preinstalled |

`locale-gen` builds a locale from its source description so programs can use it. Enabling it in
`/etc/locale.gen` (not just generating it once) means it survives later rebuilds, e.g. after a
glibc update.

## Edge cases

- **Locale names are flexible:** `ja_JP`, `ja_JP.utf8` and `ja_JP.UTF-8` all mean the same thing.
  The installer always stores `.UTF-8` — the configs assume UTF-8.
- **Arch Docker image:** only a few locales (including `en_US`) can be generated. The image
  deletes the others' source files to save space (`NoExtract` in `/etc/pacman.conf`). A real
  Arch install has all of them. The installer warns and the shells fall back to `C.UTF-8`.
- **`LC_ALL` is set, not just `LANG`.** `LC_ALL` overrides every other locale setting. That's
  unusual (normally only `LANG` is set) but Fastlane and CocoaPods need a UTF-8 `LC_ALL`.
  If you want, say, English messages with Finnish date formats, `LC_ALL` gets in the way —
  `unset LC_ALL` in `~/.zshenv.local` and set `LC_TIME=fi_FI.UTF-8` there.
- **Linux desktops** may also read `~/.config/locale.conf` (Arch's `/etc/profile.d/locale.sh`
  does), so the choice can affect more than your shell there.
