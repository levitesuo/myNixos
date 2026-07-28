{ config, pkgs, ... }:

let
  vpnResolveScript = pkgs.writeShellScript "vpn-up-resolve" ''
    ${pkgs.systemd}/bin/resolvectl dns "$1" 10.1.25.4
    ${pkgs.systemd}/bin/resolvectl domain "$1" vpn.internal
  '';

  vpnHostsScript = pkgs.writeShellScript "vpn-up-hosts" ''
    IP=$(${pkgs.azure-cli}/bin/az network private-dns record-set a show \
      --resource-group aino \
      --zone-name vpn.internal \
      --name office-computer \
      --query "aRecords[0].ipv4Address" -o tsv)
    ${pkgs.gnused}/bin/sed -i "/office-computer/d" /etc/hosts
    echo "$IP office-computer.vpn.internal" >> /etc/hosts
  '';
in
{
  environment.systemPackages = with pkgs; [
    (azure-cli.withExtensions [ azure-cli.extensions.aks-preview ])
    azure-storage-azcopy
  ];

  services.openvpn.servers.azure = {
    config = ''
      config /etc/openvpn/azure.conf
      disable-dco
      script-security 2
      up ${vpnResolveScript}
    '';
    updateResolvConf = false;
    autoStart = true;
  };

  systemd.services.vpn-update-hosts = {
    description = "Update /etc/hosts with office-computer VPN IP from Azure DNS";
    after = [ "openvpn-azure.service" ];
    wants = [ "openvpn-azure.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = vpnHostsScript;
    };
    wantedBy = [ "multi-user.target" ];
  };
}