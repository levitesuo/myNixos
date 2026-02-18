{ config, lib, pkgs, ...}:

{
  programs.kitty = {
    enable = true;
		shellIntegration.enableFishIntegration = true;
		settings  = {
			background_opacity = lib.mkForce 0;
			dynamic-background_opacity = "yes";
			bakcground_blur = lib.mkForce 0;
		};

    extraConfig = ''
    confirm_os_window_close 0
		cursor_trail 3
		cursor_trail_decay 0.1 0.4
		cursor_trail_threshold 1
    '';
  };
}
