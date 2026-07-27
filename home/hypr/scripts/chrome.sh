#!/usr/bin/env bash
# Google Chrome in touch mode — bound to the right-edge touch gesture.
#   --top-chrome-touch-ui : fat, finger-sized tabs/toolbar
#   --touch-events        : websites detect a touchscreen (mobile/touch paths)
#   --ozone-platform=x11  : keep XWayland; native Wayland ozone crashes the AMD
#                           Phoenix3 iGPU (same reason as Slack in configuration.nix)
exec google-chrome-stable --ozone-platform=x11 \
    --top-chrome-touch-ui=enabled --touch-events=enabled "$@"
