{ pkgs, ... }:
{
  # On-screen keyboard control script (summoned by gesture, waybar button, or key)
  xdg.configFile."hypr/scripts/toggle-osk.sh" = {
    source = ./scripts/toggle-osk.sh;
    executable = true;
  };

  # Chrome launcher that enables touch UI only in tablet mode w/o external keyboard
  xdg.configFile."hypr/scripts/chrome.sh" = {
    source = ./scripts/chrome.sh;
    executable = true;
  };

  wayland.windowManager.hyprland = {
    # hyprgrass: touchSCREEN gestures. (Hyprland's built-in gestures.workspace_swipe
    # in inputs.nix is a touchPAD gesture — a separate device, so no conflict.)
    # Version-matched to pkgs.hyprland since both come from nixpkgs 25.05.
    plugins = [ pkgs.hyprlandPlugins.hyprgrass ];

    settings = {
      plugin.touch_gestures = {
        # Higher = need to move further before a swipe registers. 4 is a calm default.
        sensitivity = 4.0;
        # 3-finger drag left/right moves between workspaces, like a touchpad.
        workspace_swipe_fingers = 3;
        # Disable hyprgrass's SINGLE-finger edge workspace-swipe (defaults to the
        # bottom edge), which otherwise steals the bottom-edge-up keyboard gesture.
        workspace_swipe_edge = "none";
        long_press_delay = 400;
      };

      # hyprgrass gesture binds. Gesture names act like keys in a normal `bind`.
      #   edge:<from>:<dir>  swipe starting at a screen edge, in a direction
      #   swipe:<n>:<dir>    n-finger swipe (n must be >= 3; 2-finger is scroll)
      bind = [
        # 3-finger swipe UP -> show the on-screen keyboard, DOWN -> hide it.
        # (3-finger left/right is the workspace swipe, configured above.)
        ", swipe:3:u, exec, $HOME/.config/hypr/scripts/toggle-osk.sh show"
        ", swipe:3:d, exec, $HOME/.config/hypr/scripts/toggle-osk.sh hide"
        # Edge swipes (single finger, from a screen edge inward/down):
        ", edge:l:r, exec, rofi -show drun"                    # left edge  -> launcher
        ", edge:r:l, exec, $HOME/.config/hypr/scripts/chrome.sh" # right edge -> Chrome
        ", edge:u:d, killactive"                               # top edge   -> close window
      ];
    };
  };
}
