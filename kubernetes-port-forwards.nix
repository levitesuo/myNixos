{ pkgs, ... }:

# Each service gets its own loopback IP so they can all use their default
# ports without conflict (same trick kubefwd uses).
#
# Addresses:
#   127.0.1.1  prod.argo
#   127.0.1.2  stage.argo

let
  kubeconfig = "/home/leevisuo/.kube/config";

  mkPortForward = { name, context, namespace, service, port, address }: {
    inherit name;
    value = {
      description = "kubectl port-forward ${service} → ${address} (${context})";
      after    = [ "network-online.target" "openvpn-azure.service" ];
      wants    = [ "network-online.target" ];
      bindsTo  = [ "openvpn-azure.service" ];
      wantedBy = [ "multi-user.target" ];
      path     = [ pkgs.kubectl pkgs.kubelogin ];
      serviceConfig = {
        ExecStart = "${pkgs.kubectl}/bin/kubectl"
          + " --kubeconfig ${kubeconfig}"
          + " --context ${context}"
          + " -n ${namespace}"
          + " port-forward --address ${address}"
          + " svc/${service} ${toString port}:${toString port}";
        Restart    = "always";
        RestartSec = "10s";
        User  = "leevisuo";
        Group = "users";
        # Allow binding to privileged ports (443) as non-root
        AmbientCapabilities  = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        Environment = [
          "HOME=/home/leevisuo"
          "KUBECONFIG=${kubeconfig}"
        ];
      };
    };
  };

  forwards = [
    { name = "kube-pf-prod-argo";  context = "aino-production"; namespace = "argocd"; service = "argocd-server"; port = 443; address = "127.0.1.1"; }
    { name = "kube-pf-stage-argo"; context = "aino-staging";    namespace = "argocd"; service = "argocd-server"; port = 443; address = "127.0.1.2"; }
  ];
in
{
  networking.hosts = {
    "127.0.1.1" = [ "prod.argo" ];
    "127.0.1.2" = [ "stage.argo" ];
  };

  systemd.services = builtins.listToAttrs (map mkPortForward forwards);
}
