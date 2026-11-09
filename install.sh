#!/usr/bin/env bash
# ⢞⡷ install.sh: Install omarchy-paletty engine, hooks, shell plugin, and bindings
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
HOOKS_DIR="${HOME}/.config/omarchy/hooks/theme-set.d"
PLUGINS_DIR="${HOME}/.config/omarchy/plugins/camkerr81.image-picker"
HYPR_BINDINGS="${HOME}/.config/hypr/bindings.lua"
MENU_EXT="${HOME}/.config/omarchy/extensions/omarchy-menu.jsonc"

echo "⢞⡷ Installing omarchy-paletty..."

# 1. Install CLI binaries
mkdir -p "${BIN_DIR}"
install -m 755 "${SCRIPT_DIR}/bin/omarchy-paletty-roll" "${BIN_DIR}/omarchy-paletty-roll"
ln -sf "omarchy-paletty-roll" "${BIN_DIR}/omarchy-paletty-wallpaper-cycle"
ln -sf "omarchy-paletty-roll" "${BIN_DIR}/omarchy-theme-roll"
ln -sf "omarchy-paletty-roll" "${BIN_DIR}/omarchy-theme-wallpaper-cycle"
echo "  ⠕⣀ Installed binaries to ${BIN_DIR}"

# 2. Install Omarchy theme-set hooks
mkdir -p "${HOOKS_DIR}"
install -m 755 "${SCRIPT_DIR}/hooks/theme-set.d/15-agy-theme" "${HOOKS_DIR}/15-agy-theme"
install -m 755 "${SCRIPT_DIR}/hooks/theme-set.d/20-paletty-roll" "${HOOKS_DIR}/20-paletty-roll"
echo "  ⠕⣀ Installed theme hooks to ${HOOKS_DIR}"

# 3. Install Quickshell ImagePicker plugin
mkdir -p "${PLUGINS_DIR}"
cp -p "${SCRIPT_DIR}/plugins/camkerr81.image-picker/"* "${PLUGINS_DIR}/"
echo "  ⠕⣀ Installed ImagePicker plugin to ${PLUGINS_DIR}"

# 4. Add keybinding to Hyprland if missing
if [[ -f "${HYPR_BINDINGS}" ]]; then
  if ! grep -q "omarchy-paletty-wallpaper-cycle" "${HYPR_BINDINGS}"; then
    cat >> "${HYPR_BINDINGS}" <<'EOF'

-- Cycle to next wallpaper matched from wallpaper-api / Wallhaven
o.bind("SUPER + ALT + W", "Cycle matched wallpaper", "omarchy-paletty-wallpaper-cycle")
EOF
    echo "  ⠕⣀ Added SUPER+ALT+W keybinding to ${HYPR_BINDINGS}"
    if command -v hyprctl &>/dev/null; then
      hyprctl reload &>/dev/null || true
    fi
  else
    echo "  ⠕⣀ Keybinding already present in ${HYPR_BINDINGS}"
  fi
fi

# 5. Pre-stage initial palette in background
if [[ -x "${BIN_DIR}/omarchy-paletty-roll" ]]; then
  "${BIN_DIR}/omarchy-paletty-roll" --prepare-next &>/dev/null || true
fi

echo "⢞⡷ Installation complete! Available controls:"
echo "   * Inside Theme Chooser: Ctrl+R (Roll Theme) | Ctrl+W (Cycle Wallpaper)"
echo "   * Hyprland Global:     SUPER + ALT + W (Cycle Wallpaper)"
echo "   * CLI:                 omarchy-paletty-roll | omarchy-paletty-wallpaper-cycle"
