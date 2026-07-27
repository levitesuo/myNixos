{ hostname, ... }:
let
	laptopMonitors = [
		"DP-2, preferred, 0x0, 1"
		"DP-1, 2560x1440@59.95, 3440x0, 1"
		"eDP-1, 1920x1200@60, 760x1440, 1"
	];

	workstationMonitors = [
		"DP-3, preferred, 0x0, auto"
		"HDMI-A-2, preferred, auto-right, 1"
	];
in
{
	wayland.windowManager.hyprland.settings.monitor =
		if hostname == "ls-laptop" then laptopMonitors
		else if hostname == "ls-workstation" then workstationMonitors
		else [];
}
