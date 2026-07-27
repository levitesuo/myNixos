
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
				# Draw without waiting on the background image. Suspend is held
				# until the compositor reports the session locked, so anything
				# hyprlock blocks on before its first commit is time the machine
				# spends awake and unlocked.
				immediate_render = true;
				# A bare Enter is not a guess; don't spend the fail_timeout
				# lockout of the input field on one.
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
