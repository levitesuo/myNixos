{ ... }:
{
	programs.nixvim.plugins.conform-nvim = {
		enable = true;
		settings = {
			formatters_by_ft = {
				terraform = [ "terraform_fmt" ];
				tf = [ "terraform_fmt" ];
				hcl = [ "terragrunt_hclfmt" ];
			};
			format_on_save = {
				timeout_ms = 500;
				lsp_fallback = true;
			};
		};
	};
}
