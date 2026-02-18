
{ pkgs, ... }:
{
	programs.hyprlock = {
		enable = true;
		label = {
			text = "He there $USER";
		};
	};
}
