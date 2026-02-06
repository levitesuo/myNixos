{pkgs, lib, ... }:
{
    programs.vscode = {
        enable = true;
        profiles.default.userSettings = lib.mkForce {
            # ... your existing font settings ...
            "editor.fontFamily" = "'JetBrains Mono', 'Symbols Nerd Font Mono', monospace";
            # This forces the numbers to be "tabular" (uniform height/width)
            "editor.fontLigatures" = "'calt', 'liga', 'tnum'"; 
            "editor.fontWeight" = "400";
            "editor.letterSpacing" = 0.5;
            "editor.fontSize" = 14;
            "workbench.colorTheme" = "Stylix";
            
            # General Formatting
            "editor.formatOnSave" = true;
            "editor.defaultFormatter" = "esbenp.prettier-vscode";

            # Language-specific overrides for Prettier
            "[javascript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
            "[typescript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
            "[json]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
            "[html]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
            "[css]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
            "[markdown]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        };

        # Make sure the Prettier extension is actually installed
        extensions = with pkgs.vscode-extensions; [
            esbenp.prettier-vscode
        ];
    };
}