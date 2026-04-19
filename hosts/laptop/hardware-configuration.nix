# PLACEHOLDER — replace this file by running on the laptop:
#   sudo nixos-generate-config
# then copy /etc/nixos/hardware-configuration.nix here.
# Make sure the /boot (EFI) partition is included for dual-boot with Windows.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # TODO: replace with actual laptop root partition UUID
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/REPLACE-WITH-LAPTOP-ROOT-UUID";
      fsType = "ext4";
    };

  # TODO: replace with actual EFI partition UUID (required for dual-boot with Windows)
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/REPLACE-WITH-LAPTOP-EFI-UUID";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
