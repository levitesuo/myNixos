{ config, lib, pkgs, ...}:
let
    # Public half of the SSH key 1Password signs commits with, copied from the
    # key's "public key" field in the vault. One line, algorithm name first:
    #
    #     signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... leevisuo";
    #
    # Paste it bare. The `key::` prefix that git wants is added below, and the
    # allowed-signers file needs the unprefixed form, so this stays the single
    # place the key is written down; nothing else here has to be edited to turn
    # signing on.
    #
    # Signing, and every file derived from the key, stays off while this is
    # null. That is deliberate rather than unfinished: once a signing format is
    # configured, git refuses to create *any* commit when the key is missing or
    # cannot actually sign, so a placeholder or a guessed key here takes away
    # the ability to commit at all. Only the real key belongs here.
    signingKey = null;

    # Every committer address this one key signs under. ~/.gitconfig sets the
    # personal address globally and ~/.gitconfig-work overrides it under
    # ~/work/, so the same key legitimately produces signatures attributed to
    # either name. ssh-keygen decides *trust* from the key alone, but anything
    # that checks a signature against a named identity — `ssh-keygen -Y verify
    # -I <address>`, or a forge validating an uploaded allowed-signers list —
    # rejects an address that is not listed here, so both have to be present.
    signingPrincipals = [
        "leevi.suotula@gmail.com"
        "leevi@boulevardtech.fi"
    ];

    allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
in
{
    # Catches the two pastes that would otherwise look fine to Nix and only
    # surface later as git refusing to commit: the value copied back with the
    # `key::` prefix already on it (git would then look for a key literally
    # named "key::ssh-..."), and the private half copied instead of the public
    # one, which would put signable material into the world-readable store.
    assertions = [
        {
            assertion = signingKey == null || (
                !lib.hasPrefix "key::" signingKey
                && !lib.hasInfix "PRIVATE KEY" signingKey
                && !lib.hasInfix "\n" signingKey
            );
            message =
                "home/git.nix: signingKey must be the bare, single-line public key"
                + " (\"ssh-ed25519 AAAA... comment\"). The \"key::\" prefix is added"
                + " automatically, and the private half must stay in 1Password.";
        }
    ];

    programs.git = {
        # Without this the whole module is inert and nothing here is written,
        # which is how the signing settings below would silently do nothing.
        # The generated file is ~/.config/git/config, which git reads alongside
        # a hand-written ~/.gitconfig rather than replacing it, and loses to it
        # on any key both of them set.
        enable = true;

        userName = "leevisuo";
        userEmail = "leevi.suotula@gmail.com";

        # SSH signatures rather than GPG, with 1Password holding the private
        # half. op-ssh-sign reaches the key through the desktop app's agent, so
        # nothing signable ever lands on disk.
        #
        # Deliberately the system path and not pkgs._1password-gui: the NixOS
        # module installs the package with polkitPolicyOwners applied, and
        # referring to the un-overridden one here would pull a second 583 MB
        # copy of the app into the closure.
        #
        # op-ssh-sign only reaches the key over ~/.1password/agent.sock, and
        # that socket exists only while "Use the SSH agent" is turned on in the
        # desktop app. Until it is, signing fails with "Could not connect to
        # socket. Is the agent running?" however correct this config is. The
        # toggle lives in ~/.config/1Password/settings/settings.json, which the
        # app rewrites whenever any setting changes, so it is left unmanaged:
        # a read-only store symlink there would stop the app saving its own
        # settings. ~/.1password/agent.toml, which the app only reads, could be
        # managed from here and deliberately is not — creating it switches the
        # agent from "offer every key in every unlocked vault" to "offer only
        # the items listed", so a file naming the wrong vault item would hide
        # the signing key instead of exposing it. With no agent.toml the key is
        # reachable by default.
        signing = {
            format = "ssh";
            signer = "/run/current-system/sw/bin/op-ssh-sign";

            # Passed through verbatim as user.signingKey. The `key::` form is
            # what tells git the value is a public key whose private half lives
            # in an agent: git writes it to a temporary file and calls the
            # signer with -U. Handing over a bare "ssh-..." string happens to
            # work through a backward-compatibility path git documents as
            # deprecated, and a bare path would need the public key written out
            # as a second file just to be pointed at.
            key = if signingKey == null then null else "key::${signingKey}";

            # Covers tags as well as commits: home-manager derives both
            # commit.gpgSign and tag.gpgSign from this one value, so tags stay
            # in step without a second setting to forget.
            signByDefault = signingKey != null;
        };

        # Without this, locally made signatures verify as "Good ... No
        # principal matched" and count as untrusted, because git has no list
        # saying which keys are allowed to sign for whom. Set only alongside a
        # real key: pointing it at a file that does not exist makes every
        # verification print "Unable to open allowed keys file" and still fail.
        #
        # push.gpgSign is deliberately absent. Push certificates are a separate
        # server-side feature, and GitHub does not advertise it, so enabling
        # this would make every push abort rather than add any protection.
        extraConfig = lib.optionalAttrs (signingKey != null) {
            gpg.ssh.allowedSignersFile = allowedSignersFile;
        };

        aliases = {
            # Simple aliases
            ga = "add";
            co = "checkout";
            
            # The '!' tells git to run this as a shell command
            # 'f() { ... }; f' is a standard pattern for git aliases with arguments
            gc = "!f() { git commit -m \"$*\"; }; f";
            
            # Pull then Push
            gp = "!git pull && git push";
            gs = "status";
            };
    };

    # Generated rather than hand-maintained so it cannot drift from the key
    # above, and omitted entirely while that key is null so no half-written
    # entry or literal "null" is ever produced. One entry, both addresses as
    # principals, matching the allowed-signers syntax ssh-keygen expects:
    # comma-separated principals, then the key.
    xdg.configFile = lib.optionalAttrs (signingKey != null) {
        "git/allowed_signers".text =
            "${lib.concatStringsSep "," signingPrincipals} ${signingKey}\n";
    };
}
