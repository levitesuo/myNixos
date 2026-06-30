{ lib, inputs, ... }:
let
  # Every flake input except `self`.
  flakeInputs = lib.filterAttrs (name: _: name != "self") inputs;
in
{
  # Keep this system's flake inputs from being garbage-collected.
  #
  # `nix.gc` runs `nix-collect-garbage --delete-old`, which removes any store
  # path not reachable from a GC root — including the source trees of flake
  # inputs, which are otherwise only referenced during evaluation. When that
  # happens, the next `nixos-rebuild` fails with
  #   error: path '/nix/store/…-source/flake.nix' does not exist
  # until the input is re-fetched over the network.
  #
  # Symlinking each input's source under /etc makes it part of the system
  # closure (a GC root), so it survives garbage collection. This covers the
  # direct inputs (nixpkgs, home-manager, stylix, …); transitive inputs still
  # rely on the tarball cache / a network re-fetch on the next rebuild.
  environment.etc = lib.mapAttrs' (name: flake: {
    name = "nix/inputs/${name}";
    value.source = flake.outPath;
  }) flakeInputs;

  # Point the registry and NIX_PATH at the pinned inputs so ad-hoc commands
  # (`nix shell nixpkgs#…`, `<nixpkgs>`) resolve to the same revisions as the
  # system instead of re-downloading a channel.
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
  nix.nixPath = [ "/etc/nix/inputs" ];
}
