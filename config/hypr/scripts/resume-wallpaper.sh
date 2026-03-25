#!/bin/bash
# Restart hyprpaper after resume from suspend.
# NVIDIA doesn't preserve VRAM across suspend, so wallpaper textures come
# back corrupted. A fresh hyprpaper process re-uploads clean textures.
pkill hyprpaper
sleep 1
su -l akumar -c "WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 hyprpaper &"
