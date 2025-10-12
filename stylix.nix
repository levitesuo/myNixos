{ pkgs, ... }:

{
	stylix = {
		enable = true;
		base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
		image = ./paul-chadeisson-solstice-prequel-062.jpg;
		fonts = {
			serif = {
				package = pkgs.sourcecodepro;
				name = "SourceCodePro";
			};

			sansSerif = {
				package = pkgs.sourcecodepro;
				name = "SourceCodePro";
			};

			monospace = {
				package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
				name = "JetBrainsMono Nerd Font";
			};

			emoji = {
				package = pkgs.noto-fonts-emoji;
				name = "Noto Color Emoji";
			};
		};
	};
}
