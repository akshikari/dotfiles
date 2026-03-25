#!/bin/bash
# Restart Wayland clients after resume from suspend.
# NVIDIA doesn't preserve VRAM across suspend, so GPU-backed surfaces come
# back corrupted. Restarting forces a clean re-upload of textures.
sleep 1

WAYLAND_ENV="WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000"

pkill hyprpaper
pkill waybar

# If hyprlock was running, kill and immediately re-lock so it redraws clean.
# The ~500ms gap before re-lock is acceptable on a personal machine.
if pgrep hyprlock > /dev/null; then
    pkill hyprlock
    sleep 0.5
    su -l akumar -c "$WAYLAND_ENV loginctl lock-session"
fi

su -l akumar -c "$WAYLAND_ENV hyprpaper &"
su -l akumar -c "$WAYLAND_ENV waybar &"
