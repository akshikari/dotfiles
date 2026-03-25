#!/bin/bash
# Restart Wayland clients after resume from suspend.
# NVIDIA doesn't preserve VRAM across suspend, so GPU-backed surfaces come
# back corrupted. Restarting forces a clean re-upload of textures.
# Note: hyprlock is intentionally NOT restarted — killing it while it holds
# the Wayland session lock breaks the lock protocol and leaves the session
# in an unrecoverable state.
sleep 1

WAYLAND_ENV="WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000"

pkill hyprpaper
pkill waybar

su -l akumar -c "$WAYLAND_ENV hyprpaper &"
su -l akumar -c "$WAYLAND_ENV waybar &"
