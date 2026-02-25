{ ... } :
{
    services.hypridle = {
		enable = true;
        general = {
            lock_cm = "pid hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
            {
               timeout = 120;
               on-timeout = "brightnessctl set 10";
               on-resume = "brightnessctl -r";
            }
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
}
