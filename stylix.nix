{ pkgs, ... }:

{
    fonts.packages = with pkgs; [
				nerd-fonts.sauce-code-pro
        nerd-fonts.symbols-only
    ];

    stylix = {
        enable = true;
        base16Scheme = ./color-theme.yaml;
        image = ./black-pattern.jpg;
    };
}
