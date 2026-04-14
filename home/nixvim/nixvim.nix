{ ...}:
let
	nixvim = import (builtins.fetchGit { 
			url = "https://github.com/nix-community/nixvim";
			ref = "nixos-25.05";
			narHash = "sha256-zEyZ8bMOzXkwpIizl8xtWoP2w2fiZ0bbrIt7DxjQgME=";
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
		./conform.nix
		./gitsigns.nix
		./which-key.nix
		./git-diff-search.nix
		./markdown.nix
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
