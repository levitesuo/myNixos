{...}:
{
	imports = [ ./fonts.nix ];
	services.dunst = {
		enable = true;
		settings = {
			global = {
				font = "JetBrainsMono Nerd Font";
			};
		};
	};
}
