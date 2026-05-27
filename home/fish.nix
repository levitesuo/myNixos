{ config, lib, pkgs, ...}:

{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      # Git
      ga   = "git add";
      gaa  = "git add --all";
      gs   = "git status";
      gss  = "git status --short";
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
			gr   = "git restore"; 
			gra  = "git restore .";

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

    functions = {
      fish_greeting = "";

      to_stereo = ''
        set card (pactl list cards short | grep bluez | awk '{print $2}')
        if test -z "$card"
          echo "No Bluetooth card found"
          return 1
        end
        pactl set-card-profile $card a2dp-sink
        and echo "Switched to stereo (A2DP): $card"
      '';

      to_headset = ''
        set card (pactl list cards short | grep bluez | awk '{print $2}')
        if test -z "$card"
          echo "No Bluetooth card found"
          return 1
        end
        pactl set-card-profile $card headset-head-unit
        and echo "Switched to headset (HSP/HFP): $card"
      '';

      nix-build = ''
        set dotfiles $HOME/.dotfiles
        set host (hostname)

        if not contains $host ls-laptop ls-workstation
            echo "Unknown host '$host' — expected 'ls-laptop' or 'ls-workstation'"
            return 1
        end
        set flake_target (string replace 'ls-' "" $host)

        set dirty (git -C $dotfiles status --porcelain)
        if test -n "$dirty"
            echo "Uncommitted changes:"
            git -C $dotfiles status --short
            echo ""
            echo "[1] Commit with a message"
            echo "[2] Amend previous commit"
            echo "[3] Generate commit message with Claude"
            echo "[q] Abort"
            read -l -P "Choice: " choice
            switch $choice
                case 1
                    read -l -P "Commit message: " msg
                    if test -z "$msg"
                        echo "Commit message cannot be empty"
                        return 1
                    end
                    git -C $dotfiles add --all
                    git -C $dotfiles commit -m $msg
                    or return 1
                case 2
                    git -C $dotfiles add --all
                    git -C $dotfiles commit --amend --no-edit
                    or return 1
                case 3
                    echo "Generating commit message..."
                    set diff (git -C $dotfiles diff --stat; git -C $dotfiles diff | head -150)
                    set msg (echo $diff | claude -p "Write a concise git commit message (max 72 chars) for these changes. Output only the message, nothing else." --model claude-haiku-4-5-20251001)
                    if test -z "$msg"
                        echo "Failed to generate commit message"
                        return 1
                    end
                    echo "Proposed message: $msg"
                    read -l -P "Use this message? [Y/n/e(dit)]: " confirm
                    switch $confirm
                        case ''' Y y
                            # use as-is
                        case e E
                            read -l -P "Edit message: " edited
                            test -n "$edited" && set msg $edited
                        case '*'
                            echo "Aborted"
                            return 0
                    end
                    git -C $dotfiles add --all
                    git -C $dotfiles commit -m $msg
                    or return 1
                case '*'
                    echo "Aborted"
                    return 0
            end
        end

        # Derive a profile name from the latest commit message
        set raw (git -C $dotfiles log -1 --pretty=%s)
        set base (echo $raw | tr ' /' '-' | tr -cd '[:alnum:]._-' | string sub -l 60)
        test -z "$base"; and set base build

        # Find a unique name — increment [#] prefix if profile already exists
        set label $base
        set n 1
        set pdir /nix/var/nix/profiles/system-profiles
        while test -L "$pdir/$label"
            set n (math $n + 1)
            set label "[$n]$base"
        end

        echo "=> Building NixOS ($host) — $label"
        sudo nixos-rebuild switch --flake $dotfiles#$flake_target --profile-name $label

        # Prune: keep only the 5 most recent profiles
        set old_profiles (ls -dt $pdir/*/ 2>/dev/null | tail -n +6)
        for p in $old_profiles
            sudo nix-env -p $p --delete-generations old 2>/dev/null
        end
      '';

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
