{ ... }:
{
    wayland.windowManager.hyprland.settings = {
            input = {
                kb_layout = "us";
                kb_variant = "altgr-intl";
            };
            device = [
            {
                name = "at-translated-set-2-keyboard";
                kb_layout = "fi";
                kb_variant = "";
            }
            {
                name = "tpps/2-elan-trackpoint";
                sensitivity = -0.75;
            }
            ];
    };
}                