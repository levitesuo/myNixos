{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (azure-cli.withExtensions [ azure-cli.extensions.aks-preview ])
  ];

    services.openvpn.servers.azure = {
        # This is the correct way to point to an external file without 
        # wrapping it in a second 'config' directive.
        config = "config /etc/openvpn/azure.conf";
        updateResolvConf = true;
        autoStart = true;
  };
}