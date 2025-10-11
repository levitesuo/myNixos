{ config, lib, pkgs, ...}:

{
  imports = [
    ./fonts.nix
  ];
  programs.kitty = {
    enable = true;
		themeFile = "GruvboxMaterialDarkHard";
		shellIntegration.enableFishIntegration = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    extraConfig = ''
    background_opacity 0.5
		background_blur 12
    confirm_os_window_close -1
		cursor_trail 3
		cursor_trail_decay 0.1 0.4
		cursor_trail_threshold 1
    '';
  };
}
