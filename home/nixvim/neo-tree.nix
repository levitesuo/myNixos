{ ... }:
{
	programs.nixvim.plugins.neo-tree = {
		enable = true;
		enableGitStatus = true;
		closeIfLastWindow = true;
	};

	programs.nixvim.keymaps = [
		{
			action = ":Neotree toggle<CR>";
			key = "<leader>e";
			options = {
				silent = true;
				desc = "Open file browser";
			};
		}
	];
}
