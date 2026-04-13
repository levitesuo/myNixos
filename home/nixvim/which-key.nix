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
      ];
    };
  };
}
