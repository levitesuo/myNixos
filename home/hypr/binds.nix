{ ... }:
{
	wayland.windowManager.hyprland.settings = {
		"$mainMod" = "SUPER";


		bind = [
# Programs and scripts
			"$mainMod, SPACE, exec, kitty"
				"$mainMod, C, killactive"
				"$mainMod, G, exec, google-chrome-stable --ozone-platform=x11"
				"$mainMod, P, exec, hyprshot env HYPRSHOT_DIR=/home/leevisuo/Pictures/Screenshots hyprshot -m region"
				"$mainMod, W, exec, killall -SIGUSR1 waybar"

# Dwiddle and toggle split
				"$mainMod, J, togglesplit, # dwindle"
				"$mainMod, K, swapsplit"

# Bind window movement
				"$mainMod, up, movefocus, u"
				"$mainMod, down, movefocus, d"
				"$mainMod, left, movefocus, l"
				"$mainMod, right, movefocus, r"

# Reload home-manager
				"$mainMod, H, exec, sh -c 'home-manager switch --flake ~/.dotfiles/ && dunstify \" Home Manager\" \"Configuration successfully applied! \" || dunstify -u critical \" Home Manager\" \"Configuration failed to apply! \"'"
		] ++ (
# Bind workspaces to SUPER + <num>
				builtins.concatLists(builtins.genList(i:
						let ws = i + 1;
						in [
						"$mainMod, code:1${toString i}, workspace, ${toString ws}"
						"$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
						]
						)
					9)
				);

		bindm = [
# Bind drag windows with mouse
			"$mainMod, mouse:272, movewindow"
				"$mainMod, mouse:273, resizewindow"
		];

		bindl = [
# Bind laptopt vol and brightness keys
			",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
				",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
				",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
				",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
				",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
				",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"

# Bind play, pause, next-track, prev-track
				", XF86AudioNext, exec, playerctl next"
				", XF86AudioPause, exec, playerctl play-pause"
				", XF86AudioPlay, exec, playerctl play-pause"
				", XF86AudioPrev, exec, playerctl previous"
		];
	};
}
