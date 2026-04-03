#!/bin/bash
chosen=$(printf "󰐥  Shut Down\n󰜉  Restart\n󰤄  Suspend\n󰍃  Log Out\n󰌾  Lock" \
  | wofi --dmenu \
         --prompt "" \
         --width 220 \
         --height 204 \
         --no-actions \
         --cache-file /dev/null \
         --hide-scroll)

case "$chosen" in
  *"Shut Down"*)  systemctl poweroff ;;
  *"Restart"*)    systemctl reboot ;;
  *"Suspend"*)    systemctl suspend ;;
  *"Log Out"*)    hyprctl dispatch exit ;;
  *"Lock"*)       loginctl lock-session ;;
esac
