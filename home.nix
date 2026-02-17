{ pkgs, inputs, ... }:

{

  imports =[
    ./home/nixvim/nixvim.nix
		./home/vscode.nix
    ./home/kitty.nix
    ./home/fish.nix
		./home/starship.nix
		./home/hypr/hyprland.nix
		./home/dunst.nix
    ./home/rofi.nix
    ./home/git.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "leevisuo";
  home.homeDirectory = "/home/leevisuo";

	nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    libnotify
    hyprshot
    hyprlock
    # Install Sauce Code Pro patched by Nerd Fonts so Waybar CSS can use it
    nerd-fonts.sauce-code-pro
    # keep symbols-only set for icons
    nerd-fonts.symbols-only
    kdePackages.dolphin
    ngrok
    nodePackages.eas-cli
		bluetuith
		lazydocker
		lazysql
		inputs.stormy.packages.x86_64-linux.stormy
		btop
  ];
	

  # Set Dolphin as default file manager
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
    };
  };

	services.playerctld.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
	programs.poetry.enable = true;
}
