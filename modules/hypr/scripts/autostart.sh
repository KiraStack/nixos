#!/bin/sh
# deprecated.

# Use a wallpaper daemon (using sww).
sww init &
swww img ~/pics/ &

# Can be installed by adding
# `pkgs.networkmanagerapplet` as a package.
nm-applet --indicator &

# Use other packages.
waybar &
dunst
