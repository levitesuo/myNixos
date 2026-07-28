{ config, pkgs, ... }:

let
  # The office machine's address on the VPN is handed out by DHCP and published
  # as an A record in the private zone, so it has to be looked up rather than
  # written down.
  vpnHost = "office-computer.vpn.internal";

  # Tag on the single /etc/hosts line this unit owns, so a rerun can find that
  # line again without guessing. It is matched as the last two fields of a line
  # rather than as a substring — see the awk program below, where being loose
  # about this is what made the previous version destructive.
  hostsMarkerWord = "vpn-update-hosts";
  hostsMarker = "# ${hostsMarkerWord}";

  vpnResolveScript = pkgs.writeShellScript "vpn-up-resolve" ''
    ${pkgs.systemd}/bin/resolvectl dns "$1" 10.1.25.4
    ${pkgs.systemd}/bin/resolvectl domain "$1" vpn.internal
  '';

  vpnHostsScript = pkgs.writeShellScript "vpn-up-hosts" ''
    # This runs as root against the file every name lookup on the machine goes
    # through, so nothing below may proceed on a half-known address. -e is
    # deliberately absent: the lookup is expected to fail sometimes, and is
    # retried rather than treated as fatal.
    set -uo pipefail

    lookup() {
      ${pkgs.azure-cli}/bin/az network private-dns record-set a show \
        --resource-group aino \
        --zone-name vpn.internal \
        --name office-computer \
        --query "aRecords[0].ipv4Address" -o tsv
    }

    # What comes back is remote data on its way into root's name resolution, and
    # az has several ways of handing back something that is not an address: an
    # empty string when the record set exists but carries no A record, and — seen
    # at boot, before the network can reach login.microsoftonline.com — a Python
    # traceback on stderr with nothing at all on stdout. The unvalidated version
    # of this script turned that empty result into the line " ${vpnHost}"
    # in /etc/hosts. Insist on a dotted quad. Leading zeros are refused as well:
    # inet_aton reads those as octal, so an entry could resolve somewhere other
    # than where it plainly reads.
    valid() {
      local octet='(0|[1-9][0-9]{0,2})' component
      [[ $1 =~ ^$octet\.$octet\.$octet\.$octet$ ]] || return 1
      for component in "''${BASH_REMATCH[@]:1}"; do
        [ "$component" -le 255 ] || return 1
      done
    }

    # At boot this starts as soon as openvpn does, which is well before the
    # tunnel carries traffic, and there is no wait-online provider on this
    # machine to order against — so retry instead of ordering.
    ip=""
    for attempt in 1 2 3 4 5; do
      candidate=$(lookup) || candidate=""
      if valid "$candidate"; then
        ip=$candidate
        break
      fi
      echo "vpn-up-hosts: no usable address for ${vpnHost} yet (attempt $attempt)" >&2
      [ "$attempt" = 5 ] || sleep 5
    done

    # Leaving the entry out is the right outcome once the address cannot be
    # learned, and it must not be reported as a unit failure. This is a
    # convenience entry, and a failed oneshot would both hold the system in
    # degraded state and make every nixos-rebuild switch exit non-zero while
    # off the VPN. The lines above are the record that it did not happen.
    if [ -z "$ip" ]; then
      echo "vpn-up-hosts: giving up, leaving ${vpnHost} out of /etc/hosts" >&2
      exit 0
    fi

    # /etc/hosts belongs to NixOS — networking.hosts and the host name are
    # declared there — so this rewrite has to carry every line it did not write
    # itself through untouched, and it has to replace the /etc/hosts entry
    # rather than write through it: right after activation that entry is a
    # symlink into the read-only store.
    #
    # Building the replacement beside it and renaming means a lookup racing the
    # update sees either the old file or the new one. The in-place sed this
    # replaces left a window in which /etc/hosts had no localhost entry.
    tmp=$(${pkgs.coreutils}/bin/mktemp /etc/.hosts.vpn-up.XXXXXX)
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

    # Exactly two shapes of line are dropped: one this unit wrote, recognised by
    # the marker occupying the final two fields, and the bare two-field form
    # earlier versions wrote before the marker existed — which is also how the
    # malformed empty-address entries they left behind get cleaned up.
    #
    # Both tests are anchored at the end of the line and compare whole fields,
    # because the loose versions of either one destroy entries that should have
    # survived: matching the marker anywhere in the line takes out a comment
    # that merely mentions it, and matching the hostname anywhere takes out a
    # line where this host is one alias among several, aliases and all.
    ${pkgs.gawk}/bin/awk -v markerWord='${hostsMarkerWord}' -v host='${vpnHost}' '
      NF >= 2 && $(NF - 1) == "#" && $NF == markerWord { next }
      NF <= 2 && $NF == host { next }
      { print }
    ' /etc/hosts > "$tmp"
    echo "$ip ${vpnHost} ${hostsMarker}" >> "$tmp"

    # Match the mode NixOS ships /etc/hosts with, before it becomes visible
    # under that name.
    ${pkgs.coreutils}/bin/chmod 0444 "$tmp"
    ${pkgs.coreutils}/bin/mv -f "$tmp" /etc/hosts
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

      # Runs as root because it renames a file into /etc, and az needs root's
      # token cache in /root/.azure — so neither a read-only /etc nor
      # ProtectHome can be used here. What is left is everything this unit
      # demonstrably has no use for: it needs no capabilities at all (it owns
      # both /etc and the file it replaces), loads no modules, touches no
      # kernel knobs, clock or cgroups, and speaks only IP. AF_NETLINK stays
      # allowed because glibc's getaddrinfo enumerates local addresses over it
      # and az would otherwise fail to resolve anything.
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "@system-service" ];
      # /etc/hosts gets its mode set explicitly; anything else this unit leaves
      # behind — az's token cache, its logs — has no business being readable by
      # anyone but root.
      UMask = "0077";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
