#!/bin/sh
# Hyprland total refresh script

# Reload Hyprland config
hyprctl reload

# Restart wallpaper
pkill -x hyprpaper
hyprctl hyprpaper wallpaper 'eDP-1, /home/archie/.config/hypr/images/stock.png, cover'

# Debug message
echo "\`Hyprland\` update triggered at $(date +%H:%M:%S)"

