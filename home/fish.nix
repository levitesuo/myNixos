{ config, lib, pkgs, ...}:

{
  programs.fish = {
    enable = true;
    
    # Add npm global binaries to PATH
    shellInit = ''
      # Add npm global packages to PATH
      set -gx PATH $HOME/.npm-global/bin $PATH
      
      # Set npm prefix for global packages
      set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
      
      # Auto-start Hyprland on tty1
      if test (tty) = "/dev/tty1" -a -z "$WAYLAND_DISPLAY"
        exec Hyprland
      end
      '';
  };
}
