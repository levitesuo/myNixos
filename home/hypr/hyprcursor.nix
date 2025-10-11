{ pkgs, ... }:
{
  home.pointerCursor = {
    enable = true; 
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };
}
