#!/usr/bin/env bash
# Fuzzy-find open Hyprland windows via rofi and focus the selection.
# Searches across: title, class, initialClass, workspace name.

# Three tab-separated fields: address | display text | icon name
DATA=$(hyprctl clients -j | jq -r '
  .[] | select(.mapped and .title != "") |
  [
    .address,
    "[\(.workspace.name)] \(.title)  ·  \(
      if .initialClass != "" and .initialClass != .class
      then "\(.initialClass) / \(.class)"
      else .class
      end
    )",
    (.class | ascii_downcase)
  ] | join("\t")
')

[ -z "$DATA" ] && exit 0

# Build rofi input with icon metadata inline (null bytes must not be stored in vars)
SELECTED=$(while IFS=$'\t' read -r _addr display icon; do
    printf '%s\0icon\x1f%s\n' "$display" "$icon"
  done <<< "$DATA" \
  | rofi -dmenu -i -p "  Windows" \
         -matching fuzzy \
         -sort \
         -no-custom \
         -show-icons \
         -format 's')

[ -z "$SELECTED" ] && exit 0

ADDR=$(printf '%s\n' "$DATA" \
  | awk -F'\t' -v sel="$SELECTED" '$2 == sel { print $1; exit }')

[ -n "$ADDR" ] && hyprctl dispatch focuswindow "address:$ADDR"
