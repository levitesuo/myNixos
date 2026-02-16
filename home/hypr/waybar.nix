{ ... }:
{
	programs.waybar = {
		enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 20;
				modules-right = [ "bluetooth" "pulseaudio"  "clock" ];
				modules-center = [ "hyprland/workspaces" ];
				modules-left = [ "battery" "network" ];
				
				"clock" = {
					format = "[{:%H:%M}]";
				};

				"pulseaudio" = {
					format = "[{icon} {volume}%]";
					format-muted = "󰖁 {volume}%";
					format-icons.default = ["" "" ""];
				};

				"bluetooth" = {
					format = "[{icon} {num_connections}]";
					format-icons.default = "";
				};

				"hyprland/workspaces" = {
					format = "[{name}:{windows} ]";
					format-window-separator = " ";
					window-rewrite-default = "";
					window-rewrite = {
						"title<.*youtube.*>" = "";
						"class<Google-chrome>" = "";
						"class<kitty>" = "";
						"class<Spotify>" = "";
						"class<discord>" = "";
						"code" = "";
						"title<.*nvim.*" = "";
						"slack" = "";
					}; 
				};

				"network" = {
					format = "[{icon} {essid}]";
					format-wifi = "[{icon} {essid}]";
					format-disconnected = "[󰤮]";
					format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
				};

				"battery" = {
					format = "[{icon} {capacity}%]";
					format-charging = "[{icon} {capacity}%]";
					format-icons = ["󰁹" "󰁺" "󰁻" "󰁼" "󰁽"];
				};
			};
		};
		style = ''
            * {
                font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono";
                font-size: 13px;
            }
        '';
	};
}
