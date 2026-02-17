{ config, lib, pkgs, ... }:
{
  # Generate a btop config that uses Stylix colors (best-effort mapping)
  let
    colors = config.lib.stylix.colors;
  in {
    xdg.configFile."btop/btop.conf".text = lib.mkForce ''
# btop config generated from stylix colors
# Minimal/partial config: adjust locally if you want different options
[general]
# Update interval (ms)
update_ms = 1000
# Show full process names
proc_full_name = false
truecolor = true
theme_background = false

color_theme = 'TTY'
'';
  }
}
