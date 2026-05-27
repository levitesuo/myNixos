# Edit this configuration file to define what should be installed onconfi
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, stylix, inputs, unstable, hostname, ... }:
{
  imports =
    [ ./docker.nix
      ./nodejs.nix
			./stylix.nix
      ./azure-and-vpn.nix
      ./kubernetes-port-forwards.nix
    ];

	
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
  };

  networking.hostName = hostname;
	networking.firewall.checkReversePath = "loose";

  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    General = {
      EnableNetworkConfiguration = true;
      LogLevel = "debug";
    };
    DriverQuirks = {
      UseDefaultInterface = false;
    };
  };

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
NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    MOZ_ENABLE_WAYLAND = "1";
    CLUTTER_BACKEND = "wayland";
    TERM = "xterm-256color";
    CHROME_DRIVER_PATH = "${pkgs.chromedriver}/bin/chromedriver";
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
		graphics.enable = true;
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
    wireplumber.extraConfig."bluetooth" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
      "monitor.bluez.rules" = [
        {
          matches = [ { "device.name" = "~bluez_card.*"; } ];
          actions.update-props = {
            "bluez5.auto-connect" = [ "a2dp_sink" ];
          };
        }
      ];
    };
  };


  #Define shell
  environment.shells = with pkgs; [ fish ];
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.leevisuo = {
    isNormalUser = true;
    description = "Leevi Suotula";
    extraGroups = [ "wheel" "docker" "network" ];
    shell = pkgs.fish;
    packages = with pkgs; [
			socat
			spotify
			vlc
      slack
			hyprpicker
			google-chrome
			iio-hyprland
			jq
      dbeaver-bin
      uv
      python3
      chromium
      chromedriver
			posting
      libreoffice
			minikube
    ]
    ++ (with unstable; [
      wiremix
      claude-code
    ]);
  };

  fonts.packages = with pkgs; [
    noto-fonts-emoji
  ];

  services.postgresql = {
    enable = true;
    settings.port = 5599;
  };

	home-manager.extraSpecialArgs = {
		inherit inputs stylix hostname;
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

	programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
		(azure-cli.withExtensions [ azure-cli.extensions.aks-preview])
		kubectl
		kubelogin
		kubernetes-helm
		terraform
		terragrunt
		pre-commit
		ripgrep
    git
    wl-clipboard
		cliphist
    xdg-utils
    udisks2
    gnome-disk-utility
    iwd
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    brightnessctl
  ];

	services.resolved.enable = true;
	services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  system.stateVersion = "25.05";


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

	programs.iio-hyprland.enable = true;

	services.logind.extraConfig = ''
		HandlePowerKey=suspend
		HandleLidSwitch=suspend
	'';
	# ...


}


