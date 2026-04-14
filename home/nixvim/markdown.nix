{ ... }:
{
  programs.nixvim = {
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
    ];
  };
}
