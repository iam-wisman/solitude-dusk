#!/bin/bash
# omarchy:summary=Apply the theme's VS Code colour theme to every VS Code profile, not just Default
#
# Omarchy's own VS Code step installs the theme's extension and sets
# workbench.colorTheme in the Default profile only. This hook runs after it
# and brings every other profile in line: it installs the extension the
# theme names in vscode.json into each profile that lacks it (from the
# theme's bundled vscode.vsix when there is one, else from the Marketplace),
# then copies Default's colour theme into each profile's settings.json.

THEME="$HOME/.local/state/omarchy/current/theme"
CODE_USER="$HOME/.config/Code/User"
STORAGE="$CODE_USER/globalStorage/storage.json"
DEFAULT_SETTINGS="$CODE_USER/settings.json"

command -v code >/dev/null || exit 0
[[ -f $STORAGE && -f $DEFAULT_SETTINGS ]] || exit 0
omarchy-toggle-enabled skip-vscode-theme-changes 2>/dev/null && exit 0

theme_name=$(sed -nE 's/.*"workbench\.colorTheme"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$DEFAULT_SETTINGS" | head -n1)
[[ -n $theme_name ]] || exit 0

extension=""
[[ -f $THEME/vscode.json ]] && extension=$(jq -r '.extension // empty' "$THEME/vscode.json")
[[ $extension =~ ^[a-zA-Z0-9._-]+$ ]] || extension=""

has_extension() {
  [[ -f $1 ]] && jq -e --arg id "$extension" 'any(.[]; (.identifier.id | ascii_downcase) == ($id | ascii_downcase))' "$1" >/dev/null 2>&1
}

install_extension() {
  local source=$extension
  [[ -f $THEME/vscode.vsix ]] && source=$THEME/vscode.vsix
  code --install-extension "$source" --force "$@" >/dev/null 2>&1
}

# The extension in Default (Omarchy skips the Marketplace install when it is
# already there, and a theme that is not on the Marketplace never gets it)
if [[ -n $extension ]] && ! has_extension "$HOME/.vscode/extensions/extensions.json"; then
  install_extension
fi

# Every named profile that keeps its own settings
jq -r '.userDataProfiles // [] | .[]
  | select((.useDefaultFlags.settings // false) | not)
  | select(.location | startswith("builtin/") | not)
  | [.location, .name] | @tsv' "$STORAGE" |
  while IFS=$'\t' read -r location name; do
    dir="$CODE_USER/profiles/$location"
    [[ -d $dir ]] || continue

    if [[ -n $extension ]] && ! has_extension "$dir/extensions.json"; then
      install_extension --profile "$name"
    fi

    settings="$dir/settings.json"
    [[ -f $settings ]] || printf '{\n}\n' >"$settings"

    # settings.json is JSONC, so edit in place like Omarchy does instead of
    # round-tripping through a strict JSON parser
    escaped=${theme_name//&/\\&}
    escaped=${escaped//|/\\|}
    if ! grep -q '"workbench.colorTheme"' "$settings"; then
      sed -i --follow-symlinks -E '0,/\{/{s/\{/{\ "workbench.colorTheme": "",/}' "$settings"
    fi
    sed -i --follow-symlinks -E \
      "s|(\"workbench.colorTheme\"[[:space:]]*:[[:space:]]*\")[^\"]*(\")|\1$escaped\2|" \
      "$settings"
  done
