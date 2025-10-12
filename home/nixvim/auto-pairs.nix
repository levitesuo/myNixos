{ ... }:
{
	programs.nixvim.plugins.nvim-autopairs = {
		enable = true;
		settings = {
			disable_filetype = [
				"TelescopePrompt"
			];
			map_cr = true;
			check_ts = true;
			enable_moveright = true;
		};
	};
}
