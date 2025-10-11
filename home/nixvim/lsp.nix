{ nixvim, ...}:
{
	imports = [ ./cmp.nix ];
	programs.nixvim.plugins.lsp = {
		enable = true;
		servers = {
			ts_ls.enable = true;
			lua_ls.enable = true;
			nixd.enable = true;
		};
	};
}
