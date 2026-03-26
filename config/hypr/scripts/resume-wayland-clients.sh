#!/bin/bash
# Restart Wayland clients after resume from suspend.
# NVIDIA doesn't preserve VRAM across suspend, so GPU-backed surfaces come
# back corrupted. Restarting forces a clean re-upload of textures.
# Both waybar and hyprpaper auto-discover HYPRLAND_INSTANCE_SIGNATURE from
# $XDG_RUNTIME_DIR/hypr/ — only WAYLAND_DISPLAY and XDG_RUNTIME_DIR are
# needed, set via the systemd service's Environment= directives.
#
# Note: hyprlock is intentionally NOT restarted — killing it while it holds
# the Wayland session lock breaks the lock protocol and leaves the session
# in an unrecoverable state.
sleep 1

pkill hyprpaper
pkill waybar

hyprpaper &
waybar &
