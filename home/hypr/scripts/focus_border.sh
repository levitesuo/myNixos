#!/usr/bin/env bash
# Listen to Hyprland events and briefly set a brighter active border on focus,
# then fade it back to the inactive color.
# Usage: focus_border.sh [INACTIVE_COLOR] [ACTIVE_COLOR]
# Example:
#   focus_border.sh "rgba(595959aa)" "rgba(33ccffee) 45deg"

# Default colors (keeps previous behaviour if no args passed)
INACTIVE_COLOR_DEFAULT="rgba(595959aa)"
ACTIVE_COLOR_DEFAULT="rgba(33ccffee) 45deg"
# Default delay (seconds) before reverting to inactive color
DELAY_DEFAULT=0.1

# Args: [INACTIVE_COLOR] [ACTIVE_COLOR] [DELAY]
INACTIVE_COLOR="${1:-$INACTIVE_COLOR_DEFAULT}"
ACTIVE_COLOR="${2:-$ACTIVE_COLOR_DEFAULT}"
DELAY="${3:-$DELAY_DEFAULT}"

# File where the current editor working directory is persisted
EDITOR_DIR_FILE="${XDG_RUNTIME_DIR:-/tmp}/current_editor_dir"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<EOF
Usage: $0 [INACTIVE_COLOR] [ACTIVE_COLOR] [DELAY]

Listens for Hyprland focus events and sets the active border to
ACTIVE_COLOR, then after DELAY seconds reverts it to INACTIVE_COLOR.

Examples:
  $0 "rgba(595959aa)" "rgba(33ccffee) 45deg" 0.5
  $0 "#595959aa" "#33ccffee 45deg" 0.2
EOF
  exit 0
fi

if ! command -v socat >/dev/null 2>&1; then
  echo "socat is required but not installed; aborting" >&2
  exit 1
fi

# REVERT_PID holds the background timer process that will revert the color.
REVERT_PID=""

cleanup() {
  if [ -n "$REVERT_PID" ]; then
    kill "$REVERT_PID" 2>/dev/null || true
  fi
  exit 0
}
trap cleanup INT TERM EXIT

# Start or restart the revert timer: cancel previous timer if present
start_revert_timer() {
  # kill previous timer if running
  if [ -n "$REVERT_PID" ]; then
    if kill -0 "$REVERT_PID" 2>/dev/null; then
      kill "$REVERT_PID" 2>/dev/null || true
    fi
    REVERT_PID=""
  fi

  # Start a new background timer that will revert the border color
  (
    sleep "$DELAY"
    hyprctl keyword general:col.active_border "$INACTIVE_COLOR"
  ) &
  REVERT_PID=$!
}

track_editor_dir() {
  local win_info class title pid dir=""
  win_info=$(hyprctl activewindow -j 2>/dev/null) || return

  class=$(printf '%s' "$win_info" | jq -r '.class')
  title=$(printf '%s' "$win_info" | jq -r '.title')
  pid=$(printf '%s' "$win_info" | jq -r '.pid')

  case "$class" in
    code)
      # VSCode: read actual CWD from the process via /proc
      dir=$(readlink -f "/proc/$pid/cwd" 2>/dev/null)
      ;;
    kitty)
      if [[ "$title" == nvim\ * ]]; then
        local path="${title#nvim }"
        # Expand leading ~
        path="${path/#\~/$HOME}"
        if [ -d "$path" ]; then
          dir="$path"
        elif [ -f "$path" ]; then
          dir=$(dirname "$path")
        fi
      fi
      ;;
  esac

  if [ -n "$dir" ] && [ -d "$dir" ]; then
    printf '%s\n' "$dir" > "$EDITOR_DIR_FILE"
  fi
}

handle() {
  case "$1" in
    activewindowv2*)
      # Immediately set active color and (re)start the revert timer.
      hyprctl keyword general:col.active_border "$ACTIVE_COLOR"
      start_revert_timer
      track_editor_dir
      ;;
    *)
      ;;
  esac
}

# Connect to Hyprland socket and stream events into the handler
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
  while read -r line; do
    handle "$line"
  done

