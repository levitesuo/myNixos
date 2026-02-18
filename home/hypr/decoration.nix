{ ... }:
{
	wayland.windowManager.hyprland.settings.decoration = {
		rounding = 4;
		dim_inactive = true;
		dim_strength = 0.05;
		shadow = {
			enabled = true;
			range = 12;
		};
		blur = {
			enabled = true;
			size = 2;
			passes = 3;
		};

	};
}
