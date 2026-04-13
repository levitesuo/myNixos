{ lib, ... }:
{
  # If you want to use your external CSS file, keep this and REMOVE the 'style' block below.
  xdg.configFile."waybar/style.css".source = lib.mkForce ./style.css;
  xdg.configFile."waybar/scripts/openFloatingKitty.sh" = {
    source = ./scripts/openFloatingKitty.sh;
    executable = true;
  };
  # New module not yet implemented
  # cd "$(cat /run/user/1000/current_editor_dir)" && starship module directory && starship module git_branch && starship module git_status
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 15;
        # Fixed the typo here from "cloack" to "clock/calendar"
        modules-left = [ "battery" "network" "pulseaudio" "bluetooth" "custom/dir" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "custom/weather" "clock#calendar" "clock"  ];

        "clock" = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        # Using the '#' syntax allows you to have a second instance of the clock module
        "clock#calendar" = {
          format = "󰃭 {:%d-%m-%Y}";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 {volume}%";
          format-icons.default = ["" "" ""];
          on-click = "$HOME/.config/waybar/scripts/openFloatingKitty.sh wiremix --tab output";
        };

        "bluetooth" = {
          format = "󰂯 {num_connections}";
          on-click = "$HOME/.config/waybar/scripts/openFloatingKitty.sh bluetuith 500 400";
        };

        "hyprland/workspaces" = {
          format = "{name}:{windows} ";
          format-window-separator = " ";
          window-rewrite-default = "";
          window-rewrite = {
            "title<.*youtube.*>" = "";
            "class<Google-chrome>" = "";
            "class<kitty>" = "";
            "class<Spotify>" = "";
            "class<discord>" = "";
            "code" = "";
            "title<.*nvim.*>" = "";
            "slack" = "";
						"class<DBeaver>"="";
						"title<.*TRX50.*>"="";
						"title<.*K9s.*>"="";
						"title<.*✳.*>"="✳";
          };
        };

        "network" = {
          format-wifi = "{icon} {essid}";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰤮 ";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        };

        "battery" = {
          format = "{icon} {capacity}%";
          format-charging = "󱐋 {capacity}%";
          format-icons = ["󰁹" "󰁺" "󰁻" "󰁼" "󰁽"];
        };
      "custom/weather" = {
        format= "{text}";
        tooltip= true;
        interval= 300;
        exec= "curl -s 'wttr.in/?format=%t\\n' | sed 's/+//g' | sed 's/C/C /g' | sed 's/ //g'";
        on-click= "$HOME/.config/waybar/scripts/openFloatingKitty.sh 'bash -c \"curl wttr.in/Helsinki?3n; exec fish\"' 700 900";
      };
        "custom/dir" = {
        format= " {text}";
        tooltip= true;
        interval= 3600;
        signal= 8;
        # starship emits ANSI color escape sequences which Waybar will show
        # literally. Strip ANSI escapes before Waybar displays the text.
        exec= "cd \"$(cat /run/user/1000/current_editor_dir)\" && (starship module directory && starship module git_branch && starship module git_status) | perl -pe 's/\\e\\[[0-9;]*[A-Za-z]//g'";
      };
      };
    };
  };
}
