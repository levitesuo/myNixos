{ nixvim, pkgs, ... }:
{
	programs.nixvim.plugins.treesitter = {
		enable = true;
		autoLoad = true;
		grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
		settings = {
			highlight.enable = true;
			indent.enable = true;
		};
	};
}

