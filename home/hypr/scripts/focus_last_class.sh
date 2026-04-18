#!/usr/bin/env bash
# Focus the most recently focused window of CLASS that isn't the active window.
# Usage: focus_last_class.sh <window-class>
CLASS="$1"

CURRENT=$(hyprctl activewindow -j | jq -r '.address')

TARGET=$(hyprctl clients -j | jq -r \
  --arg class "$CLASS" \
  --arg current "$CURRENT" \
  '[.[] | select(.class == $class and .address != $current)]
   | sort_by(.focusHistoryID)
   | .[0].address // empty')

[ -n "$TARGET" ] && hyprctl dispatch focuswindow "address:$TARGET"
