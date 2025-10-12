{ ...}:
let
	nixvim = import (builtins.fetchGit { 
			url = "https://github.com/nix-community/nixvim";
			ref = "nixos-25.05";
			narHash = "sha256-0+hp5PqHTXEUjUnc7oFIJVILkNVC330kMeVNdayYrII=";
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
