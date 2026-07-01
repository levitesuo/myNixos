{ pkgs, lib, hostname, ... }:
{
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };

  # On the AMD laptop (Phoenix3 iGPU) the hardware cursor plane glitches under
  # load and especially across XWayland surfaces (e.g. DBeaver) — the cursor
  # disappears, flickers, or leaves artifacts. Rendering the cursor in software
  # is rock-solid at a negligible latency cost. The workstation is NVIDIA where
  # hardware cursors are fine, so scope this to the laptop.
  wayland.windowManager.hyprland.settings.cursor =
    lib.mkIf (hostname == "ls-laptop") {
      no_hardware_cursors = true;
    };
}
