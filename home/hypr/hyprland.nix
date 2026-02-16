{ ... }:
{
	imports = [ 
		./monitors.nix
		./binds.nix
		./hyprcursor.nix
		./decoration.nix
		./animation.nix
		./waybar/waybar.nix
	];
	services.hyprpaper.enable = true;
	programs.hyprlock.enable = true;
	wayland.windowManager.hyprland = {
		enable = true;
		settings = {
			exec-once = [
				"iio-hyprland"
				"sleep 1; waybar &"
				"slack &"
				"wl-paste --type text --watch cliphist store &"
				"wl-paste --type image --watch cliphist store &"
			];
			general = {
				gaps_in = 3;
				gaps_out = 5;
				border_size = 5;
				resize_on_border = true;
				layout = "dwindle";
			};
			cursor = {
				no_hardware_cursors = true;
			};

			input = {
				kb_layout = "us";
				kb_variant = "altgr-intl";
			};
			
			dwindle.pseudotile = true;
			dwindle.preserve_split = true;
			master.new_status = "master";

			windowrulev2 = [
				"float, class:^()$, title:^()$"
				"noblur, class:^()$, title:^()$"
				"norounding, class:^()$, title:^()$"
			];
		};
	};
}
