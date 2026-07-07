#!/usr/bin/env bash
# wvkbd on-screen keyboard control:  show | hide | toggle  (default: toggle)
#
# Height is taller in landscape than portrait per preference — a bigger keyboard
# when the screen is horizontal. wvkbd auto-selects -L vs -H from the current
# output orientation, so no orientation detection is needed here.
LAND=400   # -L landscape / horizontal height (bigger)
PORT=300   # -H portrait / vertical height

action="${1:-toggle}"

running() { pgrep -x wvkbd-mobintl >/dev/null; }
start()   { wvkbd-mobintl -L "$LAND" -H "$PORT" & disown; }

case "$action" in
    show)   running || start ;;
    hide)   running && pkill -x wvkbd-mobintl ;;
    toggle) if running; then pkill -x wvkbd-mobintl; else start; fi ;;
esac
