#!/bin/bash
# Install Solitude Dusk with everything it ships, then apply it.
#
# `omarchy theme install <url>` keeps the clone's .git, and Omarchy drops a
# cloned theme's *.lua, terminal configs and vscode.json every time the theme is
# applied. That loses the gradient border, animations, gum colours and the
# Kitty gold cursor trail. This script installs the theme as a plain directory
# instead, so Omarchy treats it as the user's own and stages every file.
#
# Usage:
#   git clone https://github.com/iam-wisman/solitude-dusk
#   ./solitude-dusk/install.sh
#
# It also restores the desktop customisations that go with the theme: the
# bar inset to line up with windows (rounded bottom corners), the kitten menu
# logo, workspaces coloured from the theme palette, and the bar layout. Pass
# --theme-only to install just the theme and leave the bar alone.
#
# Safe to run again: it replaces the installed theme and skips anything that is
# already in place. Files it changes outside the theme are backed up first:
# kitty.conf next to itself, everything else under
# ~/.local/state/solitude-dusk/backups.

set -euo pipefail

THEME_NAME=solitude-dusk
THEMES_DIR="$HOME/.config/omarchy/themes"
DEST="$THEMES_DIR/$THEME_NAME"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
VSCODE_VSIX=solitude-dusk-1.0.0.vsix
CURSOR_THEME=Bibata-Modern-Amber
CURSOR_SIZE=16
CURSOR_VERSION=v2.0.7
CURSOR_URL="https://github.com/ful1e5/Bibata_Cursor/releases/download/$CURSOR_VERSION/$CURSOR_THEME.tar.xz"
CURSOR_SHA256=58b7ac00ed3cb45acb6b917cb9807a553873f1cca5c91348c4abaebe638e5884
SHELL_JSON="$HOME/.config/omarchy/shell.json"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
DEFAULT_BG=dusk-02-mdjrqy.jpg
STAMP=$(date +%s)
# Kept out of the hooks dir: Omarchy runs every file there not named *.sample.
BACKUP_DIR="$HOME/.local/state/solitude-dusk/backups/$STAMP"

say() { printf '\e[35m::\e[0m %s\n' "$*"; }

install_theme() {
  local src=$1 stage

  stage=$(mktemp -d)
  tar -C "$src" --exclude=install.sh --exclude=extras --exclude=README.md -cf - . | tar -C "$stage" -xf -

  # The VS Code theme isn't on the Marketplace, so the theme carries its VSIX
  # for the vscode-profiles hook to install from
  cp "$src/extras/vscode/$VSCODE_VSIX" "$stage/vscode.vsix"

  mkdir -p "$THEMES_DIR"
  rm -rf "$DEST"
  mv "$stage" "$DEST"
  chmod 755 "$DEST"
  say "Installed theme to $DEST"
}

install_hooks() {
  local src=$1/extras/hooks hook name dest

  # cli-colors applies the theme's eza colours for ls (Omarchy doesn't), and
  # vscode-profiles carries the VS Code theme into every profile, not just
  # Default. Both run on every theme change.
  mkdir -p "$HOOK_DIR"
  for hook in "$src"/*.sh; do
    name=$(basename "$hook")
    dest=$HOOK_DIR/$name
    if [[ -f $dest ]] && cmp -s "$hook" "$dest"; then
      continue
    fi
    if [[ -f $dest ]]; then
      mkdir -p "$BACKUP_DIR/hooks"
      cp "$dest" "$BACKUP_DIR/hooks/$name"
    fi
    install -m 755 "$hook" "$dest"
    say "Installed theme-set hook $name"
  done
}

backup_vscode_settings() {
  local user=$HOME/.config/Code/User

  # The vscode-profiles hook rewrites workbench.colorTheme in every profile
  [[ -d $user ]] || return 0
  mkdir -p "$BACKUP_DIR/vscode"
  (cd "$user" && find . -maxdepth 3 -name settings.json -path './settings.json' -o -maxdepth 3 -name settings.json -path './profiles/*' |
    while read -r f; do mkdir -p "$BACKUP_DIR/vscode/$(dirname "$f")"; cp "$f" "$BACKUP_DIR/vscode/$f"; done)
}

install_plugins() {
  local src=$1/extras/plugins plugin dest

  # The bar, kitten logo and workspaces are user shell plugins; the shell
  # discovers them in ~/.config/omarchy/plugins and hot-reloads on change.
  mkdir -p "$PLUGINS_DIR"
  for plugin in "$src"/*/; do
    plugin=$(basename "$plugin")
    dest=$PLUGINS_DIR/$plugin
    if [[ -d $dest ]] && diff -rq "$src/$plugin" "$dest" >/dev/null; then
      continue
    fi
    if [[ -d $dest ]]; then
      mkdir -p "$BACKUP_DIR/plugins"
      cp -a "$dest" "$BACKUP_DIR/plugins/"
      rm -rf "$dest"
    fi
    cp -a "$src/$plugin" "$dest"
    say "Installed shell plugin $plugin"
  done
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
}

apply_bar_layout() {
  local bar=$1/extras/shell/bar.json tmp

  # Replace only the bar section of shell.json (bar choice, position and
  # layout); idle timers and anything else in the file are kept.
  [[ -f $SHELL_JSON ]] || cp "${OMARCHY_PATH:-/usr/share/omarchy}/config/omarchy/shell.json" "$SHELL_JSON"
  if jq -e --slurpfile bar "$bar" '.bar == $bar[0]' "$SHELL_JSON" >/dev/null; then
    say "Bar layout already in place"
    return
  fi
  mkdir -p "$BACKUP_DIR"
  cp "$SHELL_JSON" "$BACKUP_DIR/shell.json"
  tmp=$(mktemp)
  jq --slurpfile bar "$bar" '.bar = $bar[0]' "$SHELL_JSON" >"$tmp"
  mv "$tmp" "$SHELL_JSON"
  say "Applied bar layout (inset bar, kitten logo, themed workspaces)"
}

enable_kitty_blink() {
  # Omarchy's default kitty.conf turns blinking off after the theme include,
  # which overrides the theme's ease-in-out blink.
  [[ -f $KITTY_CONF ]] || return 0
  if grep -q '^cursor_blink_interval 0$' "$KITTY_CONF"; then
    cp "$KITTY_CONF" "$KITTY_CONF.bak.$STAMP"
    sed -i 's/^cursor_blink_interval 0$/# cursor blink comes from the theme (ease-in-out fade)/' "$KITTY_CONF"
    say "Enabled Kitty cursor blink from the theme"
  fi
}

install_cursor() {
  local dir=$HOME/.local/share/icons stage

  # hyprland.lua sets Bibata-Modern-Amber at size 16. Fetch it from the official
  # Bibata release (pinned and checksummed) into the user icon dir, so no AUR
  # package or sudo is needed.
  if [[ -f $dir/$CURSOR_THEME/index.theme ]]; then
    say "Cursor theme $CURSOR_THEME already installed"
  else
    stage=$(mktemp -d)
    curl -fsSL -o "$stage/cursor.tar.xz" "$CURSOR_URL" || { rm -rf "$stage"; say "Could not download $CURSOR_URL; cursor not installed"; return 0; }
    if ! echo "$CURSOR_SHA256  $stage/cursor.tar.xz" | sha256sum -c --quiet - >/dev/null 2>&1; then
      rm -rf "$stage"
      say "Checksum mismatch for $CURSOR_URL; cursor not installed"
      return 0
    fi
    tar -C "$stage" -xJf "$stage/cursor.tar.xz"
    mkdir -p "$dir"
    rm -rf "${dir:?}/$CURSOR_THEME"
    mv "$stage/$CURSOR_THEME" "$dir/"
    rm -rf "$stage"
    say "Installed cursor theme $CURSOR_THEME $CURSOR_VERSION from GitHub"
  fi

  # Apply now, not just at next login: Hyprland reads the cursor env at startup,
  # and GTK apps take theme and size from gsettings.
  hyprctl setcursor "$CURSOR_THEME" "$CURSOR_SIZE" >/dev/null 2>&1 || true
  if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true
  fi
}

check_icons() {
  local icons
  icons=$(<"$DEST/icons.theme")
  [[ -d /usr/share/icons/$icons || -d $HOME/.local/share/icons/$icons ]] && return
  say "Icon theme $icons is missing; install it with: omarchy pkg add yaru-icon-theme"
}

main() {
  local repo theme_only=0
  [[ ${1:-} == --theme-only ]] && theme_only=1
  repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

  command -v omarchy >/dev/null || { echo "Omarchy not found; this theme is for Omarchy." >&2; exit 1; }
  command -v jq >/dev/null || { echo "jq is required (omarchy pkg add jq)." >&2; exit 1; }

  # Work from a copy: the clone may be $DEST itself (after `omarchy theme
  # install`), which install_theme replaces.
  SRC=$(mktemp -d)
  trap 'rm -rf "$SRC"' EXIT
  tar -C "$repo" --exclude=.git -cf - . | tar -C "$SRC" -xf -

  install_theme "$SRC"
  install_hooks "$SRC"
  backup_vscode_settings
  if (( ! theme_only )); then
    install_plugins "$SRC"
    apply_bar_layout "$SRC"
  fi
  enable_kitty_blink
  check_icons
  install_cursor

  omarchy theme set "$THEME_NAME"
  omarchy theme bg set "$DEST/backgrounds/$DEFAULT_BG" >/dev/null
  omarchy restart terminal >/dev/null 2>&1 || true
  say "Solitude Dusk applied"
}

# Everything runs from main so bash has read the whole script before the
# install step can replace the directory it lives in.
main "$@"
exit
