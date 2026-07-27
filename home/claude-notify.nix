{ config, pkgs, ... }:

let
  # Stylix palette (hex without '#'); fall back to sane defaults so the module
  # still evaluates if stylix isn't present. base0E = purple, the accent that
  # sets Claude's notifications apart from the blue (normal) / red (critical)
  # frames stylix gives every other notification.
  colors =
    if builtins.hasAttr "stylix" config.lib
    then config.lib.stylix.colors
    else { base0E = "a074c4"; base07 = "ffffff"; };

  # Append-only history log. `claude-notify` is the *only* sanctioned writer,
  # and it only ever appends — nothing here truncates or overwrites it.
  inbox = "$HOME/.local/share/claude-notify/inbox.md";

  # The one command that feeds this system: appends to the log AND fires a
  # desktop notification immediately. This is the path Claude uses when you've
  # asked to be notified.
  claude-notify = pkgs.writeShellApplication {
    name = "claude-notify";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = ''
      dir="$HOME/.local/share/claude-notify"
      mkdir -p "$dir"

      if [ "$#" -gt 0 ]; then
        msg="$*"
      else
        msg="$(cat)"
      fi

      ts="$(date '+%Y-%m-%d %H:%M')"
      {
        printf '## %s\n\n' "$ts"
        printf '%s\n\n' "$msg"
        printf -- '---\n\n'
      } >> "$dir/inbox.md"

      # -a "Claude" is what the dunst rule below keys off for the purple theme.
      notify-send -a "Claude" "Claude" "$msg"
    '';
  };

  # Read-only viewer for the append-only history, opened by the keybind below.
  # Deliberately cannot clear or edit the log — it only ever displays it.
  claude-notify-show = pkgs.writeShellApplication {
    name = "claude-notify-show";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      inbox="${inbox}"
      printf '\033c'
      if [ -s "$inbox" ]; then
        cat "$inbox"
      else
        printf '\n  No notifications from Claude yet.\n\n'
      fi
      printf '\n\n  [any key] close\n'
      read -rsn1 _ || true
    '';
  };
in
{
  home.packages = [ claude-notify claude-notify-show ];

  # Parallel notification "theme": a dunst rule matching notifications sent with
  # `-a "Claude"`. The section name sorts after `urgency_*` so it wins the frame
  # colour, and timeout=0 keeps requested notifications on screen until dismissed
  # so you actually see them.
  services.dunst.settings.zzz_claude = {
    appname = "Claude";
    frame_color = "#${colors.base0E}";
    foreground = "#${colors.base07}";
    timeout = 0;
  };

  wayland.windowManager.hyprland.settings = {
    # Center the read-only history window when it is summoned.
    windowrulev2 = [
      "float, class:^(claude-notify)$"
      "center, class:^(claude-notify)$"
      "size 900 600, class:^(claude-notify)$"
      "stayfocused, class:^(claude-notify)$"
    ];

    # Super+N pulls up the append-only history (the live popups arrive on their own).
    bind = [
      "$mainMod, N, exec, ${pkgs.kitty}/bin/kitty --class claude-notify ${claude-notify-show}/bin/claude-notify-show"
    ];
  };
}
