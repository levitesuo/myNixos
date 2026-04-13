#!/usr/bin/env bash
# Listen to Hyprland events and briefly set a brighter active border on focus,
# then fade it back to the inactive color.

INACTIVE_COLOR="${1:-rgba(595959aa)}"
ACTIVE_COLOR="${2:-rgba(33ccffee) 45deg}"
DELAY="${3:-0.1}"

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

REVERT_PID=""

cleanup() {
  kill "$REVERT_PID" 2>/dev/null || true
  exit 0
}
trap cleanup INT TERM EXIT

start_revert_timer() {
  kill "$REVERT_PID" 2>/dev/null || true
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
      # Title format: "filename - project-name - Visual Studio Code"
      local project_name
      project_name=$(printf '%s' "$title" | awk -F ' - ' '{print $(NF-1)}')
      for base in "$HOME" "$HOME/Projects" "$HOME/Documents"; do
        if [ -d "$base/$project_name" ]; then
          dir="$base/$project_name"
          break
        fi
      done
      ;;
    kitty)
      if [[ "$title" == nvim\ * ]]; then
        # Kitty abbreviates path components in the title, so walk the process
        # tree from kitty's PID to find nvim and read its real cwd.
        local nvim_pid=""
        nvim_pid=$(pgrep -P "$pid" nvim 2>/dev/null | head -1)
        if [ -z "$nvim_pid" ]; then
          local child_pid
          for child_pid in $(pgrep -P "$pid" 2>/dev/null); do
            nvim_pid=$(pgrep -P "$child_pid" nvim 2>/dev/null | head -1)
            [ -n "$nvim_pid" ] && break
          done
        fi
        [ -n "$nvim_pid" ] && dir=$(readlink -f "/proc/$nvim_pid/cwd" 2>/dev/null)
      fi
      ;;
  esac

  if [ -n "$dir" ] && [ -d "$dir" ]; then
    printf '%s\n' "$dir" > "$EDITOR_DIR_FILE"
    echo "[track_editor_dir] wrote: $dir"
  fi
}

handle() {
  case "$1" in
    activewindowv2*)
      hyprctl keyword general:col.active_border "$ACTIVE_COLOR"
      start_revert_timer
      track_editor_dir
      pkill -RTMIN+8 waybar
      ;;
  esac
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
  while read -r line; do
    handle "$line"
  done
