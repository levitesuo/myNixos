{ ... }:
{
    wayland.windowManager.hyprland.settings = {
            input = {
                kb_layout = "us";
                kb_variant = "altgr-intl";

                touchpad = {
                    natural_scroll = true;        # macOS-style: content follows fingers
                    scroll_factor = 0.4;          # tame the fast default scroll speed
                    disable_while_typing = true;  # ignore palm/thumb while typing
                    tap-to-click = true;          # tap = left click
                    tap-and-drag = true;          # tap-hold-move to drag
                    drag_lock = true;             # brief lift keeps the drag alive
                    clickfinger_behavior = true;  # 2-finger tap = right, 3 = middle
                };
            };

            # 3-finger horizontal swipe to move between workspaces
            gestures = {
                workspace_swipe = true;
                workspace_swipe_fingers = 3;
            };
            device = [
            {
                name = "at-translated-set-2-keyboard";
                kb_layout = "fi";
                kb_variant = "";
            }
            {
                name = "tpps/2-elan-trackpoint";
                sensitivity = -0.75;
            }
            ];
    };
}                