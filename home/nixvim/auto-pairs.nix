{ ... }:
{
	plugins.nvim-autopairs = {
		enable = true;
		settings = {
			disable_filetype = [
				"TelescopePrompt"
			];
			map_cr = true;
			enable_moveright = true;
		};
	};
}
