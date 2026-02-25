
{ pkgs, ... }:
{
	programs.hyprlock = {
		enable = true;
		settings = {
			label = [
				{
					text = "He there $USER";
					font_size = 16;
					color = "rgba(255, 255, 255, 0.8)";
					position = "0, 160";
					halign = "center";
					valign = "center";
				}
				{
					text = "$TIME";
					font_size = 64;
					font_family = "JetBrainsMono Nerd Font";
					color = "rgba(255, 255, 255, 0.9)";
					position = "0, 80";
					halign = "center";
					valign = "center";
				}
			];
			input-field = [
				{
					size = "300, 50";
					position = "0, 0";
					halign = "center";
					valign = "center";
					placeholder_text = "Password";
					dots_center = true;
					fade_on_empty = false;
				}
			];
		};
	};
}
