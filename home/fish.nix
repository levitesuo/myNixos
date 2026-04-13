{ config, lib, pkgs, ...}:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      # Git
      ga   = "git add";
      gaa  = "git add --all";
      gs   = "git status";
      gc   = "git commit";
      gcm  = "git commit -m";
      gp   = "git push";
      gpl  = "git pull";
      gst  = "git stash";
      gstp = "git stash pop";
      gco  = "git checkout";
      gb   = "git branch";
      gd   = "git diff";
      glog = "git log --oneline --graph --decorate";

      # kubectl — base
      k    = "kubectl";
      kg   = "kubectl get";
      kd   = "kubectl describe";
      kgp  = "kubectl get pods";
      kgn  = "kubectl get nodes";
      kgs  = "kubectl get services";
      kgd  = "kubectl get deployments";
      kgi  = "kubectl get ingress";
      kgcm = "kubectl get configmap";
      kl   = "kubectl logs";
      klf  = "kubectl logs -f";
      kaf  = "kubectl apply -f";
      kdf  = "kubectl delete -f";
      kex  = "kubectl exec -it";

      # kubectl — namespaced (aino)
      kn   = "kubectl -n aino";
      kng  = "kubectl -n aino get";
      kngn = "kubectl -n aino get nodes";
      knd  = "kubectl -n aino describe";
      kngp = "kubectl -n aino get pods";
      kngs = "kubectl -n aino get services";
      kngd = "kubectl -n aino get deployments";
      knl  = "kubectl -n aino logs";
      knlf = "kubectl -n aino logs -f";
      knaf = "kubectl -n aino apply -f";
      knex = "kubectl -n aino exec -it";

      # kubectl — context switching
      "k-s" = "kubectl config use-context aino-staging";
      "k-p" = "kubectl config use-context aino-production";

      # Passwords / tokens
      db_pw   = ''az account get-access-token --resource-type oss-rdbms --query "accessToken" -o tsv'';
      argo_pw = "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode";
    };

    # Add npm global binaries to PATH
    shellInit = ''
      # Add npm global packages to PATH
      set -gx PATH $HOME/.npm-global/bin $PATH
      
      # Set npm prefix for global packages
      set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
      
      # Auto-start Hyprland on tty1
      if test (tty) = "/dev/tty1" -a -z "$WAYLAND_DISPLAY"
        exec Hyprland
      end
      '';
  };
}
