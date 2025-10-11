{  pkgs, nixvim, ...}:
{
  imports = [ 
		nixvim.homeManagerModules.nixvim
		./opts.nix
		./lsp.nix
		./telescope.nix
		./treesitter.nix
		./neo-tree.nix
		./lualine.nix
		./auto-session.nix
	];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

		globals.mapleader = " ";
		plugins.web-devicons.enable = true;

		colorschemes.gruvbox = {
			enable = true;
			settings = {
				terminal_colors = true;
			};
		};	
	};
}
