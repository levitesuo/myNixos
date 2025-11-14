{ pkgs, ... }:

{
    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
    ];

    stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
        image = ./paul-chadeisson-periwinkle-pc-02-sketch.jpg;
        fonts = {
            serif = {
                package = pkgs.sourcecodepro;
                name = "SourceCodePro, Symbols Nerd Font Mono, Noto Color Emoji";
            };

            sansSerif = {
                package = pkgs.sourcecodepro;
                name = "SourceCodePro, Symbols Nerd Font Mono, Noto Color Emoji";
            };

            monospace = {
                package = pkgs.nerd-fonts.jetbrains-mono;
                name = "JetBrainsMono Nerd Font, Symbols Nerd Font Mono, Noto Color Emoji";
            };

            emoji = {
                package = pkgs.noto-fonts-emoji;
                name = "Noto Color Emoji, Symbols Nerd Font Mono";
            };
            sizes = {
                application = 9;
                desktop = 8;
            };
        };
    };
}
