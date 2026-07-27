# 1Password desktop app and `op` CLI.
#
# Both NixOS modules exist mainly to install setgid wrappers: the desktop app
# only accepts connections from helpers it can attribute to the `onepassword`
# and `onepassword-cli` groups, so calling the bare store binaries instead of
# the wrappers breaks browser and CLI integration. `polkitPolicyOwners` is what
# lets the listed users unlock with system authentication rather than retyping
# the account password.
{ ... }:
{
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "leevisuo" ];
  };

  # 1Password refuses to talk to a browser it cannot recognise, and it matches
  # on executable name against a built-in list that the Nix-built browsers miss.
  # Both the wrapper and the wrapped binary are listed because the extension
  # handshake sees the latter.
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      chromium
      .chromium-wrapped
      google-chrome-stable
      .google-chrome-wrapped
    '';
    # 1Password rejects the file outright if it is group- or world-writable.
    mode = "0755";
  };
}
