#!/usr/bin/env bash
# Record the focused kitty window's working directory as the target that
# Super+RETURN opens a new kitty in (see kitty_editor_dir.sh).
#
# Bound to Super+Shift+RETURN. Replaces the old focus_border.sh listener that
# tracked the editor directory on every focus change — this only does work
# when explicitly invoked, so there is no per-focus overhead.

DIR_FILE="${XDG_RUNTIME_DIR:-/tmp}/current_editor_dir"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send "$@"; }

win=$(hyprctl activewindow -j 2>/dev/null) || exit 0
class=$(printf '%s' "$win" | jq -r '.class // empty')
pid=$(printf '%s' "$win" | jq -r '.pid // empty')

if [ "$class" != "kitty" ]; then
  notify "Super+RETURN dir" "Focus a kitty window first (current: ${class:-none})"
  exit 0
fi
[ -n "$pid" ] || exit 0

# Walk from kitty's pid down to the innermost descendant (shell, or whatever
# is running in it) and read that process's current working directory.
cur=$pid
while child=$(pgrep -P "$cur" 2>/dev/null | head -n1) && [ -n "$child" ]; do
  cur=$child
done

dir=$(readlink -f "/proc/$cur/cwd" 2>/dev/null)
if [ -n "$dir" ] && [ -d "$dir" ]; then
  printf '%s\n' "$dir" > "$DIR_FILE"
  notify "Super+RETURN dir set" "$dir"
else
  notify "Super+RETURN dir" "Could not read the directory"
fi
