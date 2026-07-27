{ pkgs, ... } :
let
	# Start hyprlock and give its lock surface time to reach the screen.
	#
	# --immediate skips any grace period (during which the screen unlocks on
	# input alone) and --immediate-render draws without waiting on background
	# resources, so the lock covers the display as early as possible.
	#
	# The settle delay is a deliberate fixed wait, not a handshake: neither
	# hyprlock nor Hyprland reports "the session is locked" to anything outside
	# the compositor — hyprlock never sets logind's LockedHint — so there is no
	# readiness signal available to poll. hypridle holds logind's sleep-delay
	# inhibitor while this runs, so suspend waits for us, but only up to
	# InhibitDelayMaxSec (5s by default); the bounds stay well inside that.
	lockSession = pkgs.writeShellScript "hyprlock-lock-session" ''
		export PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:$PATH"

		if ! pidof hyprlock >/dev/null 2>&1; then
			${pkgs.hyprlock}/bin/hyprlock --immediate --immediate-render &
		fi

		for _ in $(seq 1 40); do
			pidof hyprlock >/dev/null 2>&1 && break
			sleep 0.025
		done

		# Cover surface creation and the first commit.
		sleep 0.75
	'';
in
{
    services.hypridle = {
		enable = true;
        settings = {
          general = {
              lock_cmd = "${lockSession}";
              # Called directly rather than via loginctl: lock-session only
              # emits a D-Bus signal and returns, so the lock would race the
              # suspend instead of completing before it.
              before_sleep_cmd = "${lockSession}";
              after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
                timeout = 300;
                on-timeout = "loginctl lock-session";
            }
            {
                timeout = 600;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
                timeout = 900;
                on-timeout = "systemctl suspend";
            }
          ];
        };
    };
}
