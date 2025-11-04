{ ... }:
{
	programs.waybar = {
		enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 20;
				modules-right = [ "bluetooth" "mpris" "pulseaudio"  "clock" ];
				modules-center = [ "hyprland/workspaces" ];
				modules-left = [ "custom/home-os" "tray" "battery" "network" ];
				
				"clock" = {
					format = "[{:%H:%M}]";
				};

				"pulseaudio" = {
					format = "[{icon} {volume}%]";
					format-muted = "󰖁 {volume}%";
					format-icons.default = ["" "" ""];
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

				"tray" = {
					icon-size = 21;
					spacing = 10;
					show-passive-items = true;
				};

				"custom/home-os" = {
					format = "[ ]";
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
