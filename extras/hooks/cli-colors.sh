#!/bin/bash
# omarchy:summary=Apply a theme's eza colours for ls, or remove them when the theme has none
#
# Omarchy's `ls` is eza, which reads ~/.config/eza/theme.yml. Themes like
# Solitude Dusk ship an eza.yml next to their colors; this hook copies it into
# place and removes it again for themes that don't have one. Man pages need no
# hook: Omarchy pipes them through bat with BAT_THEME=ansi, so they follow the
# terminal palette the theme sets.

THEME="$HOME/.local/state/omarchy/current/theme"
TARGET="$HOME/.config/eza/theme.yml"
MARKER="$HOME/.config/eza/.theme-managed"

# Only ever replace or remove a theme.yml this hook created, never a hand-written one
if [[ -f $TARGET && ! -f $MARKER ]]; then
  exit 0
fi

if [[ -f $THEME/eza.yml ]]; then
  mkdir -p "$(dirname "$TARGET")"
  cp "$THEME/eza.yml" "$TARGET"
  touch "$MARKER"
elif [[ -f $MARKER ]]; then
  rm -f "$TARGET" "$MARKER"
fi
