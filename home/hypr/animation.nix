# ----------------------------------------------------- 
# ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
# █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
#
# name "Diablo-1"
# credit https://github.com/Itz-Abhishek-Tiwari
# ----------------------------------------------------- 
{ ...	}:
{
	wayland.windowManager.hyprland.settings.animations = {
		enabled = 1;
		bezier = [
			"default, 0.05, 0.9, 0.1, 1.05"	
			"wind, 0.05, 0.9, 0.1, 1.05"
			"overshot, 0.13, 0.99, 0.29, 1.08"
			"liner, 1, 1, 1, 1"
			"bounce, 0.4, 0.9, 0.6, 1.0"
			"snappyReturn, 0.4, 0.9, 0.6, 1.0"
			"slideInFromRight, 0.5, 0.0, 0.5, 1.0"
		];
		animation = [
			"windows, 1, 2,  snappyReturn, slidevert"
			"windowsIn, 1, 2, snappyReturn, slidevert right"
			"windowsOut, 1, 2, snappyReturn, slide"
			"windowsMove, 1, 2, bounce, slide"
			"layersOut, 1, 2, bounce, slidevert right"
			"fadeIn, 1, 5, default"
			"fadeOut, 1, 5, default"
			"fadeSwitch, 1, 5, default"
			"fadeShadow, 1, 5, default"
			"fadeDim, 1, 5, default"
			"fadeLayers, 1, 5, default"
			"workspaces, 1, 3, overshot, slidevert"
			"border, 1, 1, liner"
			"layers, 1, 2, bounce, slidevert right"
			"borderangle, 1, 120, liner, loop"
		];
	};
}
