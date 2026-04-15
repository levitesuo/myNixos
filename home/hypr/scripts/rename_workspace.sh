#!/usr/bin/env bash
# Prompt for a name via rofi and rename the current workspace to "<id> - <name>"

ws_id=$(hyprctl activeworkspace -j | jq '.id')

name=$(rofi -dmenu -p "Rename workspace $ws_id" -theme-str 'window {width: 400px;}')

# If the user cancelled (empty or no input), do nothing
[ -z "$name" ] && exit 0

hyprctl dispatch renameworkspace "$ws_id" "$ws_id - $name"
