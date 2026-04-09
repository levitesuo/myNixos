{ ... }:
{
	imports = [ ./cmp.nix ];
	programs.nixvim.plugins.lsp = {
		enable = true;
		keymaps = {
			lspBuf = {
				"<F12>" = "definition";
				"<S-F12>" = "references";
			};
		};
		servers = {
			ts_ls.enable = true;
			lua_ls.enable = true;
			nixd.enable = true;
			terraformls.enable = true;
			helm_ls.enable = true;
		};
	};
}
