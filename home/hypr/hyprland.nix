{ ... }:
{
	imports = [ 
		./monitors.nix
		./binds.nix
		./hyprcursor.nix
		./decoration.nix
		./animation.nix
		./waybar.nix
	];
	services.hyprpaper.enable = true;
	wayland.windowManager.hyprland = {
		enable = true;
		settings = {
			exec-once = [
				"sleep1; waybar &"
				"slack &"
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
