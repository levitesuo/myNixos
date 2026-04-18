{ nixvim, ...}:
{
programs.nixvim.extraConfigLua = ''
  -- Keep transparent background regardless of the Stylix colour scheme.
  vim.api.nvim_set_hl(0, "Normal",       { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat",  { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn",   { bg = "none" })
  vim.api.nvim_set_hl(0, "EndOfBuffer",  { bg = "none" })
'';

programs.nixvim.opts = {
      updatetime = 100;
      relativenumber = true;
      number = true;
      ignorecase = true;
      smartcase = true;
      scrolloff = 8;
      tabstop = 2;
      shiftwidth = 2;
      autoindent = true;
			smartindent = true;
			wrap = false;
	}; 
}
