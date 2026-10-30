{ hostname, ... }:
let
	laptopMonitors = [
		"DP-2, preferred, 0x0, 1"
		"DP-1, 2560x1440@59.95, 3440x0, 1"
		"eDP-1, 1920x1200@60, 760x1440, 1"
		# The Samsung TV through the dock's DisplayPort runs 4K@60, where text
		# at scale 1 is tiny. Scale 2 gives a 1920x1080 logical desktop, placed
		# with its bottom edge level with the laptop's top edge.
		"DP-7, 3840x2160@60, 2680x360, 2"
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
