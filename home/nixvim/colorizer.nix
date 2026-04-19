{ ... }:
{
  programs.nixvim.plugins.colorizer = {
    enable = true;
    settings = {
      filetypes = [ "*" ];
      user_default_options = {
        RGB = true;
        RRGGBB = true;
        names = true;
        RRGGBBAA = true;
        rgb_fn = true;
        hsl_fn = true;
        mode = "background";
        tailwind = true;
        always_update = false;
      };
    };
  };
}
