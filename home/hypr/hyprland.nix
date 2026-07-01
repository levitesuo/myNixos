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
		./inputs.nix
		./hypridle.nix
		./hyprlock.nix

	];

    # Super+RETURN opens a new kitty in the directory recorded by set_open_dir.sh
    xdg.configFile."hypr/scripts/kitty_editor_dir.sh" = {
      source = ./scripts/kitty_editor_dir.sh;
      executable = true;
    };

    # Super+Shift+RETURN records the focused kitty's cwd as that directory
    xdg.configFile."hypr/scripts/set_open_dir.sh" = {
      source = ./scripts/set_open_dir.sh;
      executable = true;
    };

    xdg.configFile."hypr/scripts/focus_last_class.sh" = {
      source = ./scripts/focus_last_class.sh;
      executable = true;
    };

    xdg.configFile."hypr/scripts/focus_window_picker.sh" = {
      source = ./scripts/focus_window_picker.sh;
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
				"hyprlock &"
				"wl-paste --type text --watch cliphist store &"
				"wl-paste --type image --watch cliphist store &"
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
			
			dwindle.pseudotile = true;
			dwindle.preserve_split = true;
			master.new_status = "master";

			windowrulev2 = [
				"float, class:^()$, title:^()$"
				"noblur, class:^()$, title:^()$"
				"norounding, class:^()$, title:^()$"
				"float, class:^(io.github.alextren.Planify)$"
				"center, class:^(io.github.alextren.Planify)$"
				"size 1200 800, class:^(io.github.alextren.Planify)$"
			];

			# Blur rofi's layer surface so the transparent theme shows frosted glass
			layerrule = [
				"blur, rofi"
				"ignorezero, rofi"
			];
		};
	};
}
