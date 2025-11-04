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
