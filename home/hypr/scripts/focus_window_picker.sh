#!/usr/bin/env bash
# Fuzzy-find open Hyprland windows via rofi and focus the selection.
# Searches across: title, class, initialClass, workspace name.

DATA=$(hyprctl clients -j | jq -r '
  .[] | select(.mapped and .title != "") |
  "\(.address)\t[\(.workspace.name)] \(.title)  ·  \(
    if .initialClass != "" and .initialClass != .class
    then "\(.initialClass) / \(.class)"
    else .class
    end
  )"
')

[ -z "$DATA" ] && exit 0

SELECTED=$(printf '%s\n' "$DATA" \
  | cut -f2- \
  | rofi -dmenu -i -p "  Windows" \
         -matching fuzzy \
         -sort \
         -no-custom \
         -format 's')

[ -z "$SELECTED" ] && exit 0

ADDR=$(printf '%s\n' "$DATA" \
  | awk -F'\t' -v sel="$SELECTED" '$2 == sel { print $1; exit }')

[ -n "$ADDR" ] && hyprctl dispatch focuswindow "address:$ADDR"
