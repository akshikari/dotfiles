#!/bin/bash
# Restart Wayland clients after resume from suspend.
# NVIDIA doesn't preserve VRAM across suspend, so GPU-backed surfaces come
# back corrupted. Restarting forces a clean re-upload of textures.
# HYPRLAND_INSTANCE_SIGNATURE is discovered from $XDG_RUNTIME_DIR/hypr/ since
# the systemd service doesn't inherit it from the user session. WAYLAND_DISPLAY
# and XDG_RUNTIME_DIR are set via the service's Environment= directives.
#
# Note: hyprlock is intentionally NOT restarted — killing it while it holds
# the Wayland session lock breaks the lock protocol and leaves the session
# in an unrecoverable state.
sleep 1

export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ 2>/dev/null | head -1)

pkill hyprpaper
pkill waybar

hyprpaper &
waybar &
