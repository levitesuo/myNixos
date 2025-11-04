{ config, lib, pkgs, ...}:
{
    programs.rofi = {
        enable = true;
        terminal = "${pkgs.alacritty}/bin/alacritty";
        extraConfig = {
            modi = "drun";
            show-icons = true;
            drun-display-format = "{icon} {name}";
            sidebar-mode = false;
            matching = "fuzzy";
            sort = true;
            disable-history = false;
            cycle = true;
            auto-select = false;
            font = "JetBrains Mono Nerd Font 12";
            icon-theme = "Papirus";
        };
        
        theme = lib.mkForce (let
            inherit (config.lib.formats.rasi) mkLiteral;
            colors = config.lib.stylix.colors;
        in {
            "*" = {
                background-color = mkLiteral "transparent";
                margin = mkLiteral "0px";
                padding = mkLiteral "0px";
                spacing = mkLiteral "0px";
                font = "JetBrains Mono Nerd Font 12";
            };
            
            "window" = {
                location = mkLiteral "center";
                width = mkLiteral "600px";
                border-radius = mkLiteral "12px";
                background-color = mkLiteral "#${colors.base00}";
                border = mkLiteral "2px solid";
                border-color = mkLiteral "#${colors.base0D}";
            };
            
            "mainbox" = {
                padding = mkLiteral "12px";
                background-color = mkLiteral "transparent";
            };
            
            "inputbar" = {
                children = mkLiteral "[ prompt, entry ]";
                background-color = mkLiteral "#${colors.base01}";
                border-radius = mkLiteral "8px";
                padding = mkLiteral "8px 16px";
                margin = mkLiteral "0px 0px 12px 0px";
            };
            
            "prompt" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "#${colors.base0D}";
                margin = mkLiteral "0px 8px 0px 0px";
            };
            
            "entry" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "#${colors.base05}";
                placeholder = "Search applications...";
                placeholder-color = mkLiteral "#${colors.base04}";
                cursor = mkLiteral "text";
            };
            
            "listview" = {
                background-color = mkLiteral "transparent";
                columns = mkLiteral "1";
                lines = mkLiteral "8";
                cycle = mkLiteral "false";
                dynamic = mkLiteral "true";
                layout = mkLiteral "vertical";
                spacing = mkLiteral "4px";
            };
            
            "element" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "#${colors.base05}";
                orientation = mkLiteral "horizontal";
                border-radius = mkLiteral "6px";
                padding = mkLiteral "8px 12px";
                margin = mkLiteral "2px 0px";
            };
            
            "element-icon" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "inherit";
                size = mkLiteral "24px";
                margin = mkLiteral "0px 12px 0px 0px";
            };
            
            "element-text" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "inherit";
                vertical-align = mkLiteral "0.5";
            };
            
            "element normal.normal" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "#${colors.base05}";
            };
            
            "element selected.normal" = {
                background-color = mkLiteral "#${colors.base0D}";
                text-color = mkLiteral "#${colors.base00}";
                border-radius = mkLiteral "6px";
            };
            
            "element alternate.normal" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "#${colors.base05}";
            };
            
            "element selected.alternate" = {
                background-color = mkLiteral "#${colors.base0D}";
                text-color = mkLiteral "#${colors.base00}";
                border-radius = mkLiteral "6px";
            };
        });
    };
}