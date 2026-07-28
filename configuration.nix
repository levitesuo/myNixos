# Edit this configuration file to define what should be installed onconfi
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, stylix, inputs, unstable, hostname, ... }:
{
  imports =
    [ ./docker.nix
      ./nodejs.nix
			./stylix.nix
      ./azure-and-vpn.nix
      ./kubernetes-port-forwards.nix
      ./onepassword.nix
    ];

	
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  # Without this, anyone at the boot menu can press "e" and append
  # init=/bin/sh to the kernel command line for a root shell with no password,
  # which walks straight past the lock screen.
  boot.loader.systemd-boot.editor = false;

  # Swap holds pages evicted from RAM, so a plaintext swap partition leaks
  # whatever was in memory — keys, tokens, decrypted documents — and survives
  # power-off. Re-key it with a fresh random key on every boot instead. This
  # rules out hibernation, which is already unused: lid and power key suspend.
  #
  # Referenced by PARTUUID deliberately. Random encryption rewrites the
  # partition on every boot, so the filesystem UUID that nixos-generate-config
  # emitted stops resolving after the first boot; the partition UUID lives in
  # the GPT and survives.
  swapDevices = lib.mkIf (hostname == "ls-laptop") (lib.mkForce [{
    device = "/dev/disk/by-partuuid/4b0d16c8-3e2b-414c-b8e4-b0d01654cd36";
    randomEncryption.enable = true;
  }]);

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

	# Shared graphics stack. NVIDIA modesetting is workstation-only — the laptop
	# is an AMD Phoenix3 APU and configures amdgpu in hosts/laptop/gpu.nix.
	hardware.graphics.enable = true;
	hardware.nvidia.modesetting.enable = lib.mkIf (hostname != "ls-laptop") true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Discover network printers (AirPrint/IPP) via mDNS. The Canon X-1643P
  # supports driverless IPP Everywhere, so no proprietary driver is needed.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

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
    # No "docker" here on purpose. The rootful daemon's socket is group-owned,
    # and reaching it is enough to run a --privileged container that mounts the
    # host root, so membership would make this account root-equivalent without
    # ever passing the sudo prompt. Containers come from the rootless daemon in
    # docker.nix instead.
    extraGroups = [ "wheel" "network" ];
    shell = pkgs.fish;
    packages = with pkgs; [
			socat
			spotify
			vlc
      # Force XWayland: native Wayland ozone thrashes the AMD Phoenix3 iGPU
      # buffer and crashes Slack on launch (same fix as Chrome in binds.nix).
      (slack.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/slack --add-flags "--ozone-platform=x11"
        '';
      }))
			hyprpicker
			google-chrome
			iio-hyprland
			wvkbd
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

  # No console auto-login: the tty1 password prompt is what gates access to the
  # session. fish still execs Hyprland on tty1 once that prompt is satisfied,
  # so logging in still lands straight in the compositor.

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
    pandoc
  ];

	services.resolved.enable = true;
	services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # hyprlock authenticates through PAM, but there is no /etc/pam.d/hyprlock
  # unless we declare one — it silently falls back to /etc/pam.d/su, which
  # happens to work while making the screen lock depend on su's stack.
  # logFailures keeps the failed-attempt logging su's stack already gave us.
  security.pam.services.hyprlock = {
    enableGnomeKeyring = true;
    logFailures = true;
  };

  system.stateVersion = "25.05";


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

	programs.iio-hyprland.enable = true;

	services.logind.extraConfig = ''
		HandlePowerKey=suspend
		HandleLidSwitch=suspend
	'';
	# ...


}


