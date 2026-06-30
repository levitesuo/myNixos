{ ... }:
{
	programs.nixvim.plugins.octo = {
		enable = true;
		settings = {
			# Use telescope as the picker (telescope is already enabled).
			picker = "telescope";
			default_to_projects_v2 = true;
			enable_builtin = true;
		};
	};

	# Global keybinds. Octo also sets up its own buffer-local mappings inside
	# octo buffers (PR/issue views) which which-key picks up automatically.
	programs.nixvim.keymaps = [
		# PRs
		{ key = "<leader>opl"; action = "<cmd>Octo pr list<CR>";     options = { silent = true; desc = "List PRs"; }; }
		{ key = "<leader>opc"; action = "<cmd>Octo pr create<CR>";   options = { silent = true; desc = "Create PR"; }; }
		{ key = "<leader>opo"; action = "<cmd>Octo pr checkout<CR>"; options = { silent = true; desc = "Checkout PR"; }; }
		{ key = "<leader>opr"; action = "<cmd>Octo review start<CR>"; options = { silent = true; desc = "Start review"; }; }

		# Issues
		{ key = "<leader>oil"; action = "<cmd>Octo issue list<CR>";   options = { silent = true; desc = "List issues"; }; }
		{ key = "<leader>oic"; action = "<cmd>Octo issue create<CR>"; options = { silent = true; desc = "Create issue"; }; }

		# Misc
		{ key = "<leader>os"; action = "<cmd>Octo search<CR>"; options = { silent = true; desc = "Search GitHub"; }; }
	];
}
