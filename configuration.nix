# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, stylix, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "33" ]; # Android 13
    buildToolsVersions = [ "33.0.2" ];
    includeEmulator = true;
    systemImageTypes = [ "google_apis" ]; # Use "google_apis_playstore" for Play Store
    abiVersions = [ "x86_64" ]; # For most modern emulators
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./docker.nix
      ./nodejs.nix
      ./android.nix
    ];

	# Colorscheme
	stylix.enable = true;
	stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
	stylix.image = ./paul-chadeisson-solstice-prequel-062.jpg; 
	
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
    General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };


	environment.sessionVariables = {
		WLR_NO_HARDWARE_CURSOR = "1";
		NIXOS_OZONE_WL = "1";
		# Additional Wayland/Hyprland environment variables
		XDG_CURRENT_DESKTOP = "Hyprland";
		XDG_SESSION_TYPE = "wayland";
		XDG_SESSION_DESKTOP = "Hyprland";
	};

  
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };

	hardware = {
		opengl.enable = true;
		nvidia.modesetting.enable = true;
	};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  #Define shell
  environment.shells = with pkgs; [ fish ];
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.leevisuo = {
    isNormalUser = true;
    description = "Leevi Suotula";
    extraGroups = [ "networkmanager" "wheel" "docker"	"kvm" "adbusers" ];
    shell = pkgs.fish;
    packages = with pkgs; [
			networkmanagerapplet
      slack
			hyprpicker
			google-chrome
    ];
  };

	home-manager.extraSpecialArgs = {
		inherit  stylix;
	};

	home-manager.backupFileExtension = ".bak";

	home-manager.users.leevisuo = {
		imports = [ 
				./home.nix 
			];
			home.stateVersion = "25.05";
	};

  # Configure console auto-login and start Hyprland
  services.getty.autologinUser = "leevisuo";
  
  # Enable Hyprland system-wide
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
		ripgrep
    git
    wl-clipboard
    xdg-utils
    udisks2
    gnome-disk-utility
    iwd
    androidComposition.androidsdk
    jdk17
  ];

	services.udisks2.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Enable Android emulator
	nixpkgs.config.android_sdk.accept_license = true;

  programs.adb.enable = true;

  environment.variables.ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
  environment.variables.ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  environment.variables.JAVA_HOME = "${pkgs.openjdk17}";

}

