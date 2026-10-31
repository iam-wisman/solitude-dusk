# Solitude Dusk

A personal fork of Omarchy's stock **Solitude** theme, retuned for the last
light of the day. The palette is pulled from its two lead wallpapers: neutral
charcoal and mist greys from a moonlit mountain range, and the single golden
sun `#db9617` sinking behind a dark ridge. That gold is the accent, the cursor
and the window border; everything around it stays quiet and grey.

For daytime there is a light companion, [Solitude Dawn](https://github.com/iam-wisman/solitude-dawn).

## Install

```bash
git clone https://github.com/iam-wisman/solitude-dusk
./solitude-dusk/install.sh
```

Use the script rather than `omarchy theme install`. Omarchy treats a theme that
still has its `.git` folder as third-party and skips its Hyprland, terminal and
Neovim configs every time it is applied, so the gradient border, animations and
Kitty cursor trail would be lost. `install.sh`:

- installs the theme as a plain folder so Omarchy applies every file
- adds a `theme-set` hook that applies the theme's eza colours for `ls`
  (and removes them again when you switch to a theme without any)
- turns on the Kitty cursor blink that Omarchy's default `kitty.conf` disables
- installs the Bibata Modern Amber cursor (v2.0.7, checksum-verified) from the
  [official GitHub release](https://github.com/ful1e5/Bibata_Cursor/releases)
  into `~/.local/share/icons` and switches to it at size 16 right away
- installs the desktop customisations below (skip them with `--theme-only`)
- applies the theme and sets the default wallpaper

It is safe to re-run, and backs up any file it changes outside the theme to
`~/.local/state/solitude-dusk/backups/`.

## Desktop customisations

These are Omarchy shell plugins, kept in `extras/plugins/` and copied to
`~/.config/omarchy/plugins/`. The bar section of `~/.config/omarchy/shell.json`
is replaced with `extras/shell/bar.json`, which selects them and holds the bar
layout; the rest of `shell.json` (idle timers and so on) is left alone.

- **`wuisman.bar`:** a clone of Omarchy's bar that stays on the top edge but
  is inset 10px on each side (Hyprland's `gaps_out`) so it lines up with a
  full-width window, with its bottom corners rounded to 6px like the windows
- **`wuisman.kitten`:** replaces the Omarchy logo with a square kitten
  (`kitten.svg`), drawn in the bar's text colour so it reads on light and dark
  themes alike. Left click opens the Omarchy menu, right click a terminal
- **`wuisman.workspaces`:** a clone of the workspace switcher coloured from
  whichever theme is active: accent for the focused workspace, text colour for
  occupied ones, muted for empty ones, and the theme's red for urgent ones

The cloned plugins don't receive Omarchy's later changes to the stock bar and
workspaces. If an Omarchy update breaks the bar clone, the shell falls back
to the built-in bar; to go back to stock on purpose, set `bar.id` to
`omarchy.bar` and the layout ids back to `omarchy.menu` and
`omarchy.workspaces` in `shell.json`.

After changing a plugin on the desktop, copy it back into `extras/plugins/`
(and `jq .bar ~/.config/omarchy/shell.json > extras/shell/bar.json` for layout
changes) so the repo stays the source of truth.

## Palette

| Role | Colour | From |
|------|--------|------|
| Background | `#171717` | night sky behind the ridge |
| Surface | `#232323` / `#2d2d2d` | dark mountain layers |
| Text | `#d6d6d6` / `#e9e9e9` | moonlit peaks |
| Muted | `#6b6b6b` | far mountain haze |
| Accent | `#db9617` | the setting sun |

Solitude's ANSI colours are nearly all grey, so syntax, `ls` and man pages came
out monochrome. Dusk keeps the greys for backgrounds and text and gives the
ANSI slots soft evening colours:

| Slot | Normal | Bright |
|------|--------|--------|
| red | `#c0674a` coral | `#d9825f` |
| green | `#9ca07a` olive | `#b5b993` |
| yellow | `#db9617` sun gold | `#e8b450` |
| blue | `#8b93a6` twilight | `#a6aec0` |
| magenta | `#a38aa0` lavender | `#bca6b9` |
| cyan | `#8ea39d` mist | `#a8bdb7` |

## Changes from Solitude

- **Kitty:** configured like Macchiato Nocturne: font size 10, gold cursor with
  a gold cursor trail and a smooth ease-in-out blink, copy on select
- **ls:** an `eza.yml` theme (directories twilight blue, executables gold, git
  status, permissions and sizes graded through the palette)
- **Man pages:** Omarchy renders them through `bat` with the `ansi` theme, so
  they pick up the palette above (headings twilight blue, flags gold)
- **Window borders:** 1px "dusk glow", a gold to coral 45° gradient on the
  active window; inactive borders in `#2d2d2d` so they recede
- **Hyprland:** Solitude's soft 6px rounding, plus blur, a deep shadow and the
  slide/pop-in animations from Macchiato Nocturne
- **Mouse cursor:** [Bibata Modern Amber](https://github.com/ful1e5/Bibata_Cursor) at size 16
- **Icons:** Yaru-yellow-dark, to match the gold
- **VS Code:** its own Solitude Dusk colour theme (see below)
- **Wallpapers:** six monochrome and golden-hour wallpapers from Wallhaven

Neovim (ashen) stays as in Solitude. Everything else
(Alacritty, Ghostty, Foot, btop, the bar, Chromium and so on) is generated by
Omarchy from `colors.toml`.

## VS Code

`extras/vscode/` is a VS Code theme extension, `iam-wisman.solitude-dusk`:
editor `#171717`, side bar, title bar, status bar and panel a shade darker at
`#121212`, gold cursor, gold top edge on the active tab, and the palette's
evening colours for syntax. It is built from Omarchy's generated theme for
these colours, with hovers and the current line made visible again.

It is not on the Marketplace, so the theme carries the packaged
`solitude-dusk-1.0.0.vsix`, and the `vscode-profiles` theme-set hook:

- installs it into Default and every VS Code profile that doesn't have it yet
- sets every profile's colour theme to Default's, so all profiles follow
  whatever Omarchy theme is active (Omarchy itself only themes Default)

`install.sh` backs up every profile's `settings.json` first. Settings Sync
carries the `Solitude Dusk` theme choice to other devices, but not the
extension itself (sync only installs Marketplace extensions): run
`install.sh` on each machine. Profiles created later get the theme on the
next theme change, or by re-running `install.sh`.

To rebuild the VSIX after editing `themes/solitude-dusk-color-theme.json`,
bump `version` in `package.json` and `VSCODE_VSIX` in `install.sh`, then:

```bash
cd extras/vscode
npx @vscode/vsce package -o solitude-dusk-<version>.vsix
```

## Wallpaper credits (wallhaven.cc)

| File | Source |
|------|--------|
| `dusk-01-768zy3.jpg` | https://wallhaven.cc/w/768zy3 |
| `dusk-02-mdjrqy.jpg` | https://wallhaven.cc/w/mdjrqy |
| `dusk-03-85z1o1.jpg` | https://wallhaven.cc/w/85z1o1 |
| `dusk-04-8g5p52.jpg` | https://wallhaven.cc/w/8g5p52 |
| `dusk-05-qrdy1l.jpg` | https://wallhaven.cc/w/qrdy1l |
| `dusk-06-d8p7w3.jpg` | https://wallhaven.cc/w/d8p7w3 |
