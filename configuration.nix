# Edit this configuration file to define what should be installed onconfi
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, stylix, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./docker.nix
      ./nodejs.nix
    ];

	# Colorscheme
	stylix.enable = true;
	stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
	stylix.image = ./paul-chadeisson-paulchadeisson-03-cityprinter-1920.jpg; 
	
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
	networking.firewall.checkReversePath = "loose";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable NetworkManager
  networking.networkmanager = {
		enable = true;
		plugins = with pkgs; [
			networkmanager-openvpn
		];
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
		WLR_NO_HARDWARE_CURSOR = "1";
		NIXOS_OZONE_WL = "1";
		# Additional Wayland/Hyprland environment variables
		XDG_CURRENT_DESKTOP = "Hyprland";
		XDG_SESSION_TYPE = "wayland";
		XDG_SESSION_DESKTOP = "Hyprland";
		# Fix clipboard issues
		MOZ_ENABLE_WAYLAND = "1";
		CLUTTER_BACKEND = "wayland";
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
	services.spotifyd.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
    packages = with pkgs; [
			spotify
			spotifyd
			vlc
			networkmanagerapplet
      slack
			hyprpicker
			google-chrome
			iio-hyprland
			jq
      dbeaver-bin
    ];
  };
  fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
  nerd-fonts.symbols-only
  noto-fonts-emoji
];

  services.postgresql = {
    enable = true;
    port = 5444;
    ensureDatabases = [ "mydatabase" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
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
		(azure-cli.withExtensions [ azure-cli.extensions.aks-preview])
		pre-commit
		tailscale
		ripgrep
    git
    wl-clipboard
		cliphist
    xdg-utils
    udisks2
    gnome-disk-utility
    iwd
  ];

	services.udisks2.enable = true;
	services.tailscale.enable = true;
  system.stateVersion = "25.05";


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

	programs.iio-hyprland.enable = true;

	services.logind.extraConfig = ''
		HandlePowerKey=suspend
		HandleLidSwitch=suspend
	'';
	# ...

# create a oneshot job to authenticate to Tailscale
systemd.services.tailscale-autoconnect = {
  description = "Automatic connection to Tailscale";

  # make sure tailscale is running before trying to connect to tailscale
  after = [ "network-pre.target" "tailscale.service" ];
  wants = [ "network-pre.target" "tailscale.service" ];
  wantedBy = [ "multi-user.target" ];

  # set this service as a oneshot job
  serviceConfig.Type = "oneshot";

  # have the job run this shell script
  script = with pkgs; ''
    # wait for tailscaled to settle
    sleep 2

    # check if we are already authenticated to tailscale
    status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
    if [ $status = "Running" ]; then # if so, then do nothing
      exit 0
    fi

    # otherwise authenticate with tailscale
    ${tailscale}/bin/tailscale up -authkey tskey-auth-k5pB1jf1N121CNTRL-EhJBCQyM6W9MUSbH8ufuV9MucCKVJPVZ
  '';
};



}


