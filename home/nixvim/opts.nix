{ nixvim, ...}:
{
programs.nixvim.opts = {
      updatetime = 100;
      relativenumber = true;
      number = true;
      smartcase = true;
      scrolloff = 8;
      tabstop = 2;
      shiftwidth = 2;
      autoindent = true;
			wrap = false;
	}; 
}
