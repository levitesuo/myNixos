{ config, lib, pkgs, ...}:
let
    # Public half of the SSH key 1Password signs commits with, copied from the
    # key's "public key" field in the vault. Signing stays off while this is
    # null, because git rejects every commit once a signing format is set but
    # the key is empty.
    signingKey = null;
in
{
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
        signing = {
            format = "ssh";
            signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
            key = signingKey;
            signByDefault = signingKey != null;
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
}
