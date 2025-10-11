{ nixvim, ...}:
{
	programs.nixvim.plugins.cmp = {
		enable = true;

		settings.mapping = {
			"<C-d>" = "cmp.mapping.scroll_docs(-4)";
			"<C-f>" = "cmp.mapping.scroll_docs(4)";
			"<C-Space>" = "cmp.mapping.complete()";
			"<C-e>" = "cmp.mapping.close()";
			"<CR>" = "cmp.mapping.confirm({ select = true })";
			"<Tab>" = "cmp.mapping.select_next_item()";
			"<Down" = "cmp.mapping.select_next_item()";
			"<S-Tab>" = "cmp.mapping.select_prev_item()";
			"<Up>" = "cmp.mapping.select_prev_item()";
		};

		settings.sources = [
		{name = "path";}
		{name = "nvim_lsp";}
		{
			name = "buffer";
			option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
		}
		{name = "neorg";}
		];
	};
}
