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

	# Detect Helm template files as 'helm' filetype so the helm treesitter
	# parser is used instead of yaml (which breaks on {{ }} template syntax)
	programs.nixvim.filetype.pattern = {
		".*/templates/.*\\.yaml" = "helm";
		".*/templates/.*\\.yml"  = "helm";
		".*/templates/.*\\.tpl"  = "helm";
	};
}

