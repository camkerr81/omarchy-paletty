#!/usr/bin/env bash
# ⢞⡷ uninstall.sh: Remove omarchy-paletty binaries, hooks, and plugin
set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
HOOKS_DIR="${HOME}/.config/omarchy/hooks/theme-set.d"
PLUGINS_DIR="${HOME}/.config/omarchy/plugins/camkerr81.image-picker"

echo "⢞⡷ Removing omarchy-paletty..."

rm -f "${BIN_DIR}/omarchy-paletty-roll"
rm -f "${BIN_DIR}/omarchy-paletty-wallpaper-cycle"
rm -f "${BIN_DIR}/omarchy-theme-roll"
rm -f "${BIN_DIR}/omarchy-theme-wallpaper-cycle"

rm -f "${HOOKS_DIR}/15-agy-theme"
rm -f "${HOOKS_DIR}/20-paletty-roll"

rm -rf "${PLUGINS_DIR}"

echo "⠕⣀ Binaries, hooks, and plugin removed."
echo "Note: If desired, manually remove the SUPER+ALT+W keybinding from ~/.config/hypr/bindings.lua."
