#!/usr/bin/env bash
# Listen to Hyprland events and briefly set a brighter active border on focus,
# then fade it back to the inactive color.
# Usage: focus_border.sh [INACTIVE_COLOR] [ACTIVE_COLOR]
# Example:
#   focus_border.sh "rgba(595959aa)" "rgba(33ccffee) 45deg"

# Default colors (keeps previous behaviour if no args passed)
INACTIVE_COLOR_DEFAULT="rgba(595959aa)"
ACTIVE_COLOR_DEFAULT="rgba(33ccffee) 45deg"

INACTIVE_COLOR="${1:-$INACTIVE_COLOR_DEFAULT}"
ACTIVE_COLOR="${2:-$ACTIVE_COLOR_DEFAULT}"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<EOF
Usage: $0 [INACTIVE_COLOR] [ACTIVE_COLOR]

Listens for Hyprland focus events and sets the active border to
ACTIVE_COLOR, then after a short delay reverts it to INACTIVE_COLOR.

Examples:
  $0 "rgba(595959aa)" "rgba(33ccffee) 45deg"
  $0 "#595959aa" "#33ccffee 45deg"
EOF
  exit 0
fi

if ! command -v socat >/dev/null 2>&1; then
  echo "socat is required but not installed; aborting" >&2
  exit 1
fi

handle() {
  case "$1" in
    activewindowv2*)
      # When a window is focused, set border to active color then fade back
      hyprctl keyword general:col.active_border "$ACTIVE_COLOR"
      # short visible delay
      sleep 0.5
      hyprctl keyword general:col.active_border "$INACTIVE_COLOR"
      ;;
    *)
      ;;
  esac
}

# Connect to Hyprland socket and stream events into the handler
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
  while read -r line; do
    handle "$line"
  done

