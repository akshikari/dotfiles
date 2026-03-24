#!/bin/bash
# Screenshot helper — inline grim+slurp subshells are unreliable in Hyprland binds
#
# Usage:
#   screenshot.sh region   — select region → copy to clipboard
#   screenshot.sh full     — full screen → save to ~/Pictures/

SAVE_DIR="$HOME/Pictures/screenshots"
mkdir -p "$SAVE_DIR"

case "$1" in
  region)
    selection=$(slurp 2>/dev/null) || exit 0  # exit cleanly if user cancels
    grim -g "$selection" - | wl-copy --type image/png
    ;;
  full)
    grim "$SAVE_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    ;;
esac
