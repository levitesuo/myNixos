{ nixvim, pkgs, ... }:
{
	programs.nixvim.plugins.treesitter = {
		enable = true;
		autoLoad = true;
		grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
		settings = {
			highlight.enable = true;
			indent.enable = true;
			incremental_selection = {
				enable = true;
				keymaps = {
					init_selection = "<M-space>";
					node_incremental = "<space>";
					scope_incremental = false;
					node_decremental = "<bs>";
				};
			};
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

