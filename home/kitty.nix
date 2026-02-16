{ config, lib, pkgs, ...}:

{
  programs.kitty = {
    enable = true;
		shellIntegration.enableFishIntegration = true;
    extraConfig = ''
    confirm_os_window_close 0
    background_opacity 0.8
		transparent_background_colors #393533@0.8
		background_blur 40
		cursor_trail 3
		cursor_trail_decay 0.1 0.4
		cursor_trail_threshold 1
    '';
  };
}
