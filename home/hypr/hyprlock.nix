
{ pkgs, lib, ... }:
{
	programs.hyprlock = {
		enable = true;
		settings = {
			general = {
				# Already hyprlock's default, pinned so a later edit can't
				# quietly reintroduce a window where input alone unlocks the
				# screen without a password.
				grace = 0;
				# An empty submission is not a guess, so don't let one count
				# toward the PAM failure counter.
				ignore_empty_input = true;
				hide_cursor = true;
			};
			label = [
				{
					text = "$TIME";
					font_size = 64;
					font_family = "JetBrainsMono Nerd Font";
					color = "rgba(185, 185, 185, 0.65)";
					position = "0, 80";
					halign = "center";
					valign = "center";
				}
			];
			input-field = lib.mkForce {
				size = "300, 50";
				position = "0, 0";
				halign = "center";
				valign = "center";
				outer_color = "rgba(100, 100, 100, 0.05)";
				inner_color = "rgba(100, 100, 100, 0.01)";
				placeholder_text = "";
				dots_center = true;
				fade_on_empty = false;
			};
		};
	};
}
