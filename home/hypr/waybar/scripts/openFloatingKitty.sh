#!/usr/bin/env bash

# Parameters
script="${1:-bluetuith}"
width="${2:-400}"
height="${3:-200}"

# Generate a unique ID
uid="floating_$(uuidgen | cut -d'-' -f1)"

# Get cursor position for placement
cursor_x=$(hyprctl cursorpos -j | jq '.x')
y_offset=40 
pos_x=$(( cursor_x - (width / 2) ))
if [ "$pos_x" -lt 0 ]; then pos_x=0; fi

# Define the Window Rules
hyprctl keyword windowrulev2 "float, title:^($uid)$"
hyprctl keyword windowrulev2 "size $width $height, title:^($uid)$"
hyprctl keyword windowrulev2 "move $pos_x $y_offset, title:^($uid)$"

# Launch Kitty and capture its PID
kitty --title "$uid" -e sh -c "$script" &
kitty_pid=$!

# --- Forced Auto-close logic ---
(
    # Wait for the window to actually appear and take focus
    sleep 0.4
    
    # Check if the window is currently active
    # We loop as long as our UID matches the active window title
    while [ "$(hyprctl activewindow -j | jq -r '.title')" == "$uid" ]; do
        sleep 0.1
        # Exit early if the process was closed manually by the user
        if ! kill -0 $kitty_pid 2>/dev/null; then exit; fi
    done
    
    # Focus lost: Force kill the Kitty process and all children
    kill -9 $kitty_pid 2>/dev/null
    
    # Cleanup Hyprland rules
    hyprctl keyword windowrulev2 "unset, title:^($uid)$"
) &