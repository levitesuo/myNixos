{ nixvim, ... }:
{
	programs.nixvim.plugins.treesitter = {
		enable = true;
		autoLoad = true;
		settings = {
			highlight.enable = true;
			indent.enable = true;
		};
	};	
}

