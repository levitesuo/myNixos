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
    ./home/yazi.nix
    ./home/k9s.nix
    ./home/linear-notify.nix
    ./home/onepassword-secrets.nix
    ./home/claude-notify.nix
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
		k9s
		inputs.stormy.packages.x86_64-linux.stormy
		btop
		argocd
		bruno
		planify
		gh
		gnumake
		tmc-cli
		md-tui
		pulseaudio
  ];
	

  # Set Dolphin as default file manager
  xdg.desktopEntries."kitty-nvim" = {
    name = "Neovim (Kitty)";
    genericName = "Text Editor";
    exec = "kitty nvim %F";
    terminal = false;
    type = "Application";
    categories = [ "Utility" "TextEditor" ];
    mimeType = [
      "text/plain"
      "text/markdown"
      "text/x-markdown"
      "text/css"
      "text/xml"
      "text/x-python"
      "text/x-shellscript"
      "text/x-lua"
      "text/x-go"
      "text/x-rust"
      "text/x-c"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-c++src"
      "text/x-c++hdr"
      "text/x-java"
      "text/x-yaml"
      "text/javascript"
      "text/x-nix"
      "application/json"
      "application/xml"
      "application/x-yaml"
      "application/x-shellscript"
      "application/javascript"
      "application/typescript"
      "application/toml"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/postscript" = "org.pwmt.zathura.desktop";
      "image/vnd.djvu" = "org.pwmt.zathura.desktop";
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/x-gnome-saved-search" = "org.kde.dolphin.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/ftp" = "chromium-browser.desktop";
      "text/html" = "chromium-browser.desktop";
      "application/xhtml+xml" = "chromium-browser.desktop";
      "application/json" = "kitty-nvim.desktop";
      "text/plain" = "kitty-nvim.desktop";
      "text/markdown" = "kitty-nvim.desktop";
      "text/x-markdown" = "kitty-nvim.desktop";
      "text/css" = "kitty-nvim.desktop";
      "text/xml" = "kitty-nvim.desktop";
      "application/xml" = "kitty-nvim.desktop";
      "text/x-python" = "kitty-nvim.desktop";
      "text/x-shellscript" = "kitty-nvim.desktop";
      "application/x-shellscript" = "kitty-nvim.desktop";
      "text/x-lua" = "kitty-nvim.desktop";
      "text/x-go" = "kitty-nvim.desktop";
      "text/x-rust" = "kitty-nvim.desktop";
      "text/x-yaml" = "kitty-nvim.desktop";
      "application/x-yaml" = "kitty-nvim.desktop";
      "text/javascript" = "kitty-nvim.desktop";
      "application/javascript" = "kitty-nvim.desktop";
      "application/typescript" = "kitty-nvim.desktop";
      "application/toml" = "kitty-nvim.desktop";
      "text/x-nix" = "kitty-nvim.desktop";
    };
  };

	services.playerctld.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
	programs.poetry.enable = true;

  programs.zathura.enable = true;

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "10.254.0.16" = {
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
    };
  };
}
