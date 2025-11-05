{ config, lib, pkgs, ...}:

{
  programs.fish = {
    enable = true;
    
    # Add npm global binaries to PATH
    shellInit = ''
      # Add npm global packages to PATH
      set -gx PATH $HOME/.npm-global/bin $PATH
      
      # Set npm prefix for global packages
      set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
      
      # Auto-start Hyprland on tty1
      if test (tty) = "/dev/tty1" -a -z "$WAYLAND_DISPLAY"
        exec Hyprland
      end
      set -x ANDROID_HOME $ANDROID_SDK_ROOT
      
      # Intercept `npm run android` when in a Node project that has an
      # "android" script. This searches upwards for package.json and
      # checks if it contains an "android" script, then calls the
      # helper which ensures an emulator is running before invoking npm.
      function npm --wraps npm
        # Only handle 'npm run android' invocations; otherwise call real npm
        if not test (count $argv) -ge 2 -a $argv[1] = "run" -a $argv[2] = "android"
          command npm $argv
          return $status
        end

        # Search upward from cwd for package.json containing """android"""
        set -l cwd (pwd)
        set -l projectDir ""
        while test "$cwd" != "/" -a -n "$cwd"
          if test -f "$cwd/package.json"
            if grep -q '"android"' "$cwd/package.json" >/dev/null 2>&1
              set projectDir $cwd
              break
            end
          end
          set cwd (dirname $cwd)
        end

        if test -n "$projectDir"
          # Call helper script which starts emulator if needed, then runs npm
          $HOME/.local/bin/start-android-expo "$projectDir"
        else
          # fallback: run the real npm
          command npm $argv
        end
      end
    '';
    
    # Fish aliases for common Node.js development tasks
    shellAliases = {
      # npm shortcuts
      "ni" = "npm install";
      "nid" = "npm install --save-dev";
      "nig" = "npm install --global";
      "nr" = "npm run";
      "ns" = "npm start";
      "nt" = "npm test";
      "nb" = "npm run build";
      "nw" = "npm run watch";
      
      # yarn shortcuts
      "y" = "yarn";
      "ya" = "yarn add";
      "yad" = "yarn add --dev";
      "yr" = "yarn run";
      "ys" = "yarn start";
      "yt" = "yarn test";
      "yb" = "yarn build";
      "yw" = "yarn watch";
      
      # pnpm shortcuts
      "p" = "pnpm";
      "pi" = "pnpm install";
      "pa" = "pnpm add";
      "pad" = "pnpm add --save-dev";
      "pr" = "pnpm run";
      "ps" = "pnpm start";
      "pt" = "pnpm test";
      "pb" = "pnpm build";
    };
  };
}
