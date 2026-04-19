{ ... }:
{
  programs.nixvim.plugins.colorizer = {
    enable = true;
    settings = {
      filetypes = {
        "*" = {
          mode = "background";
        };
        css = {
          css = true;
          css_fn = true;
        };
      };
      user_default_options = {
        RGB = true;
        RRGGBB = true;
        names = true;
        RRGGBBAA = true;
        AARRGGBB = false;
        rgb_fn = true;
        hsl_fn = true;
        css = true;
        css_fn = true;
        mode = "background";
        tailwind = true;
        sass = {
          enable = true;
        };
        always_update = false;
      };
    };
  };
}
