{ pkgs, ... } :
{
    services.hypridle = {
		enable = true;
        settings = {
          general = {
              lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";

              # Hold logind's sleep-delay inhibitor until the compositor reports
              # the session actually locked over hyprland-lock-notify-v1, rather
              # than releasing it as soon as the lock command has been spawned.
              # Without this the lock would race the suspend: hypridle spawns
              # commands asynchronously, so a lock command cannot delay sleep by
              # taking longer to run.
              #
              # Mode 2 (the default) infers the same behaviour, but only by
              # substring-matching these commands for "hyprlock" and
              # "lock-session". State it outright so renaming or rewrapping a
              # command cannot silently drop the guarantee.
              #
              # This mode needs the compositor to advertise the protocol; if it
              # ever stops, hypridle warns at startup and stops inhibiting
              # rather than falling back, so check that warning before blaming
              # the lock.
              inhibit_sleep = 3;
          };
          listener = [
            {
                timeout = 300;
                on-timeout = "loginctl lock-session";
            }
            {
                timeout = 600;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
                timeout = 900;
                on-timeout = "systemctl suspend";
            }
          ];
        };
    };
}
