#!/bin/bash
# Pause/resume Hyprland around NVIDIA suspend to prevent GPU connection loss.
# Called by systemd before sleep and after wake (see hyprland-suspend/resume services).
case "$1" in
    suspend) kill -STOP $(pidof Hyprland) ;;
    resume)  kill -CONT $(pidof Hyprland) ;;
esac
