{ pkgs, ... }:

{
    fonts.packages = with pkgs; [
				nerd-fonts.sauce-code-pro
        nerd-fonts.symbols-only
    ];

    stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/selenized-black.yaml";
        image = ./black.jpg;
    };
}
