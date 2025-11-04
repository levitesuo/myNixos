{ pkgs, ... }:

let
  systemStylix = import /home/leevisuo/.dotfiles/stylix.nix { inherit pkgs; };
in
{
  # If you have a home-manager module for stylix, merge the system config and
  # override only the font size fields here.
  programs.stylix = (systemStylix // {
    enable = true;

    fonts = (systemStylix.fonts // {
      serif = (systemStylix.fonts.serif // { fontSize = 12; });
      sansSerif = (systemStylix.fonts.sansSerif // { fontSize = 11; });
      monospace = (systemStylix.fonts.monospace // { fontSize = 10; });
      emoji = (systemStylix.fonts.emoji // { fontSize = 10; });
    });
  });
}