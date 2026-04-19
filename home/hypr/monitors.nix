{ hostname, ... }:
let
	laptopMonitors = [
		"DP-2, preferred, 0x0, auto"
		"eDP-1, 1920x1200@60, auto-down, 1"
	];

	workstationMonitors = [
		"DP-3, preferred, 0x0, auto"
		"HDMI-A-2, preferred, auto-right, 1"
	];
in
{
	wayland.windowManager.hyprland.settings.monitor =
		if hostname == "laptop" then laptopMonitors
		else if hostname == "workstation" then workstationMonitors
		else [];
}
