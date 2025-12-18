{ ...}:
let
	nixvim = import (builtins.fetchGit { 
			url = "https://github.com/nix-community/nixvim";
			ref = "nixos-25.05";
			narHash = "sha256-k+y285jyeE0qrqKq1L/TMeDZO7XIk7ActLASi+niqWk=";
		});
in
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
		./auto-pairs.nix
		./auto-tag.nix
	];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

		globals.mapleader = " ";
		plugins.web-devicons.enable = true;

	};
}
