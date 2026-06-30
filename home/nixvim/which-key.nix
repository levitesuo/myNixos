{ ... }:
{
  programs.nixvim.plugins.which-key = {
    enable = true;
    settings = {
      delay = 300;
      icons.mappings = true;
      spec = [
        { __unkeyed-1 = "<leader>f"; group = "Find"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; }
        { __unkeyed-1 = "<leader>h"; group = "Hunk"; }
        { __unkeyed-1 = "<leader>e"; group = "Explorer"; }
        { __unkeyed-1 = "<leader>m"; group = "Markdown"; }
        { __unkeyed-1 = "<leader>o"; group = "Octo"; }
        { __unkeyed-1 = "<leader>op"; group = "PR"; }
        { __unkeyed-1 = "<leader>oi"; group = "Issue"; }
      ];
    };
  };
}
