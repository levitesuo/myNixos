# Secrets fetched from 1Password at login instead of living in hand-maintained
# dotfiles.
#
# Each declared env file is rendered into $XDG_RUNTIME_DIR/op-secrets/<name>.env,
# which is tmpfs-backed and private to the session, so no secret material is ever
# written to disk or to the Nix store. The templates that drive the rendering
# contain only `op://` references, never values, which is why they are safe to
# keep in the world-readable store.
{ config, lib, pkgs, ... }:

let
  cfg = config.services.onepassword-secrets;

  templateFor = name: vars:
    pkgs.writeText "op-secrets-${name}.env" (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (var: ref: "${var}=${ref}") vars) + "\n"
    );

  # Invoked through the setgid wrapper rather than `pkgs._1password-cli`: the
  # desktop app only answers a process it can attribute to the `onepassword-cli`
  # group, so the bare store binary would fail to resolve any reference.
  opSecrets = pkgs.writeShellApplication {
    name = "op-secrets";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      dir="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}/op-secrets"
      mkdir -p "$dir"
      chmod 700 "$dir"
      umask 077

      render() {
        : # keeps the function valid when nothing is declared
        ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (name: vars:
          "/run/wrappers/bin/op inject --force --in-file ${templateFor name vars} --out-file \"$dir/${name}.env\""
        ) cfg.envFiles)}
      }

      # The desktop app is normally still starting when the session reaches
      # this point, and op cannot resolve a reference before the app answers.
      # Retry for a while rather than leaving the session without its secrets.
      for attempt in 1 2 3 4 5; do
        if render; then exit 0; fi
        echo "op-secrets: render failed (attempt $attempt), retrying in 5s" >&2
        sleep 5
      done
      echo "op-secrets: giving up — is 1Password running and unlocked?" >&2
      exit 1
    '';
  };
in
{
  options.services.onepassword-secrets.envFiles = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
    default = { };
    example = lib.literalExpression ''
      {
        linear.LINEAR_API_KEY = "op://Private/Linear/credential";
      }
    '';
    description = ''
      Environment files to render from 1Password. Each attribute name becomes
      `$XDG_RUNTIME_DIR/op-secrets/<name>.env` holding one `VAR=value` line per
      entry, with the `op://` reference resolved to the live secret.

      Rendering happens once per graphical session and prompts 1Password to
      unlock if it is locked. Declaring nothing here leaves the whole mechanism
      inert, with no prompt and no calls to `op`.
    '';
  };

  config = {
    # Also available by hand, to re-render after changing a value in the vault.
    home.packages = [ opSecrets ];

    systemd.user.services.op-secrets = {
      Unit = {
        Description = "Render 1Password-backed secrets into the session runtime directory";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        # The rendered files outlive the process, so the unit should read as
        # active once it has run rather than as dead.
        RemainAfterExit = true;
        ExecStart = lib.getExe opSecrets;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
