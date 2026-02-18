{ config, lib, pkgs, ... }:
let
	# Pull colors from Stylix if present; otherwise use safe defaults so this
	# module evaluates even when stylix isn't available at evaluation time.
	colors = if builtins.hasAttr "stylix" config.lib
		then config.lib.stylix.colors
		else { base01 = "595959"; base0D = "33ccff"; };

	inactiveColor = "rgba(${colors.base01}aa)";
	activeColor = "rgba(${colors.base0D}ff)";
in
{
    imports = [ 
		./monitors.nix
		./binds.nix
		./hyprcursor.nix
		./decoration.nix
		./animation.nix
		./waybar/waybar.nix
		./hyprlock.nix
	];

    # Deploy the focus_border script into the user's hypr config so we can run it
    xdg.configFile."hypr/scripts/focus_border.sh" = {
      source = ./scripts/focus_border.sh;
      executable = true;
    };

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
				# start the focus_border listener with Stylix-derived colors
				"sh -c '$HOME/.config/hypr/scripts/focus_border.sh \"${inactiveColor}\" \"${activeColor}\" &'"
			];
			general = {
				gaps_in = 3;
				gaps_out = 5;
				border_size = 2;
				resize_on_border = true;
				layout = "dwindle";
				"col.active_border" = lib.mkForce activeColor;
				"col.inactive_border" = lib.mkForce inactiveColor;
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
