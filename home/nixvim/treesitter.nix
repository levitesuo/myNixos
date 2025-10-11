{ nixvim, ... }:
{
	programs.nixvim.plugins.treesitter = {
		enable = true;
		autoLoad = true;
	};	
}
