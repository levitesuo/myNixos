{ config, pkgs, ... }:

{
  # Install Azure CLI and extensions
  environment.systemPackages = with pkgs; [
    (azure-cli.withExtensions [ azure-cli.extensions.aks-preview ])
  ];
  services.openvpn = {
    enable = true;
    config = ''
      config /home/leevisuo/.secrets/vpn-config.ovpn
    '';
  };
}
