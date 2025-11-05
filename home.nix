{ pkgs, ... }:

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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
	nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
		libnotify
		hyprshot
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    kdePackages.dolphin
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    # Helper script to start emulator (if needed) and run the project's
    # `npm run android`. Installed as ~/.local/bin/start-android-expo
    ".local/bin/start-android-expo".text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      PROJECT_DIR="$1"
      if [ -z "$PROJECT_DIR" ]; then
        PROJECT_DIR="$HOME/Project/app-asiatudio"
      fi

      AVD_NAME="android-emu"

      ADB="$ADB"
      if [ -z "$ADB" ]; then
        ADB=adb
      fi

      EMULATOR="$EMULATOR"
      if [ -z "$EMULATOR" ]; then
        EMULATOR=emulator
      fi

      # If there's already a device (physical or emulator) attached, skip starting AVD
      if $ADB devices | awk 'NR>1 && $2=="device" { found=1; exit } END { exit !found }'; then
        echo "Device already connected."
      else
  echo "No device found, starting AVD '$AVD_NAME'..."
        # start emulator in background
  nohup $EMULATOR -avd "$AVD_NAME" >/dev/null 2>&1 &
        # wait for adb device
        echo "Waiting for emulator to become available..."
        $ADB wait-for-device
        # wait until Android reports boot complete
        for i in $(seq 1 120); do
          boot=$($ADB shell getprop sys.boot_completed 2>/dev/null || true)
          boot=$(echo "$boot" | tr -d '\r' || true)
          if [ "$boot" = "1" ]; then
            echo "Emulator booted."
            break
          fi
          sleep 1
        done
      fi

      # Run the project's npm script from the project directory
      cd "$PROJECT_DIR"
      echo "Running: npm run android (in $PROJECT_DIR)"
      npm run android
    '';

    # Make helper executable
    ".local/bin/start-android-expo".executable = true;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/leevisuo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
		HYPRSHOT_DIR = "$HOME/Pictures/Screenshots";
  };

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
}
