{ ... }:
{
	programs.nixvim.plugins.gitsigns = {
		enable = true;
		settings = {
			current_line_blame = true;
			current_line_blame_opts = {
				delay = 600;
				virt_text_pos = "eol";
			};
			signs = {
				add          = { text = "│"; };
				change       = { text = "│"; };
				delete       = { text = "_"; };
				topdelete    = { text = "‾"; };
				changedelete = { text = "~"; };
				untracked    = { text = "┆"; };
			};
		};
	};

	programs.nixvim.keymaps = [
		{ key = "]h"; action = "<cmd>Gitsigns next_hunk<CR>";    options = { desc = "Next hunk"; }; }
		{ key = "[h"; action = "<cmd>Gitsigns prev_hunk<CR>";    options = { desc = "Prev hunk"; }; }
		{ key = "<leader>hp"; action = "<cmd>Gitsigns preview_hunk<CR>"; options = { desc = "Preview hunk"; }; }
		{ key = "<leader>hs"; action = "<cmd>Gitsigns stage_hunk<CR>";   options = { desc = "Stage hunk"; }; }
		{ key = "<leader>hu"; action = "<cmd>Gitsigns undo_stage_hunk<CR>"; options = { desc = "Undo stage hunk"; }; }
		{ key = "<leader>hr"; action = "<cmd>Gitsigns reset_hunk<CR>";   options = { desc = "Reset hunk"; }; }
		{ key = "<leader>hb"; action = "<cmd>Gitsigns blame_line<CR>";   options = { desc = "Blame line"; }; }
		{ key = "<leader>hd"; action = "<cmd>Gitsigns diffthis<CR>";     options = { desc = "Diff this file"; }; }
	];
}
