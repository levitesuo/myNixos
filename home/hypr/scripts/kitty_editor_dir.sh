#!/usr/bin/env bash
# Open kitty in the editor directory tracked by focus_border.sh,
# falling back to the default kitty launch if no directory is recorded.
EDITOR_DIR_FILE="${XDG_RUNTIME_DIR:-/tmp}/current_editor_dir"
dir=$(cat "$EDITOR_DIR_FILE" 2>/dev/null)
if [ -d "$dir" ]; then
    exec kitty --directory "$dir"
else
    exec kitty
fi
