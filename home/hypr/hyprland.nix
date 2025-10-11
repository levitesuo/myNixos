{ ... }:
{
	imports = [ 
		./monitors.nix
		./binds.nix
		./hyprcursor.nix
		./decoration.nix
		./animation.nix
	];
	wayland.windowManager.hyprland = {
		enable = true;
		settings = {
			general = {
				gaps_in = 3;
				border_size = 5;
				"col.inactive_border" = "rgba(82A6B180) rgba(5B300080) 45deg";
				"col.active_border" = "rgba(82A6B1ff) rgba(5B3000ff) 45deg";
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
