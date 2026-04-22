{ pkgs, ... }:

# Each service gets its own loopback IP so they can all use their default
# ports without conflict (same trick kubefwd uses).
#
# Addresses:
#   127.0.1.1  prod.argo
#   127.0.1.2  stage.argo
#   127.0.1.3  prod.qdrant.green
#   127.0.1.4  stage.qdrant.green
#   127.0.1.5  stage.qdrant
#   127.0.1.6  prod.qdrant

let
  kubeconfig = "/home/leevisuo/.kube/config";

  mkPortForward = { name, context, namespace, service, port, address }: {
    inherit name;
    value = {
      description = "kubectl port-forward ${service} → ${address} (${context})";
      after    = [ "network-online.target" "openvpn-azure.service" ];
      wants    = [ "network-online.target" "openvpn-azure.service" ];
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
        Environment = [
          "HOME=/home/leevisuo"
          "KUBECONFIG=${kubeconfig}"
        ];
      };
    };
  };

  forwards = [
    { name = "kube-pf-prod-argo";          context = "aino-production"; namespace = "argocd"; service = "argocd-server";      port = 443;  address = "127.0.1.1"; }
    { name = "kube-pf-stage-argo";         context = "aino-staging";    namespace = "argocd"; service = "argocd-server";      port = 443;  address = "127.0.1.2"; }
    { name = "kube-pf-prod-qdrant-green";  context = "aino-production"; namespace = "aino";   service = "legal-qdrant";        port = 6333; address = "127.0.1.3"; }
    { name = "kube-pf-stage-qdrant-green"; context = "aino-staging";    namespace = "aino";   service = "legal-qdrant";        port = 6333; address = "127.0.1.4"; }
    { name = "kube-pf-stage-qdrant";       context = "aino-staging";    namespace = "aino";   service = "aino-qdrant";         port = 6333; address = "127.0.1.5"; }
    { name = "kube-pf-prod-qdrant";        context = "aino-production"; namespace = "aino";   service = "aino-qdrant-150426";  port = 6333; address = "127.0.1.6"; }
  ];
in
{
  networking.hosts = {
    "127.0.1.1" = [ "prod.argo" ];
    "127.0.1.2" = [ "stage.argo" ];
    "127.0.1.3" = [ "prod.qdrant.green" ];
    "127.0.1.4" = [ "stage.qdrant.green" ];
    "127.0.1.5" = [ "stage.qdrant" ];
    "127.0.1.6" = [ "prod.qdrant" ];
  };

  systemd.services = builtins.listToAttrs (map mkPortForward forwards);
}
