{ pkgs, ... }:
{
  programs.nixvim = {
    # Renders ```mermaid blocks (and image links) inline in markdown using
    # kitty's graphics protocol. Mermaid is converted with mmdc, other
    # formats with ImageMagick.
    plugins.snacks = {
      enable = true;
      settings.image = {
        enabled = true;
        doc = {
          enabled = true;
          inline = true;
          float = true;
        };
      };
    };
    extraPackages = [ pkgs.mermaid-cli pkgs.imagemagick ];

    plugins."render-markdown" = {
      enable = true;
      settings = {
        enabled = true;
        render_modes = [ "n" "c" "t" ];
        heading = {
          enabled = true;
          sign = true;
          icons = [ "# " "## " "### " "#### " "##### " "###### " ];
        };
        code = {
          enabled = true;
          sign = false;
          style = "full";
          border = "thin";
        };
        checkbox = {
          enabled = true;
          unchecked.icon = "  ";
          checked.icon = "  ";
        };
        bullet = {
          enabled = true;
          icons = [ "" "" "" "" ];
        };
        link = {
          enabled = true;
          image = "  ";
          hyperlink = "  ";
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>mt";
        action = "<cmd>RenderMarkdown toggle<CR>";
        options.desc = "Toggle render";
      }
      {
        mode = "n";
        key = "<leader>mi";
        action.__raw = "function() Snacks.image.hover() end";
        options.desc = "Show image/diagram under cursor";
      }
    ];
  };
}
