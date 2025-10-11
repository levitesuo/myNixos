{
	description = "My flake";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixvim-pkg = {
			url = "github:nix-community/nixvim/nixos-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};    
		stylix = {
			url = "github:danth/stylix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, nixvim-pkg, stylix, ... }:
		let
		lib = nixpkgs.lib;
	system = "x86_64-linux"; 
	pkgs = nixpkgs.legacyPackages.${system};
	in {
		nixosConfigurations = {
			nixos = lib.nixosSystem {
				inherit system;
				modules = [ 
						./configuration.nix  
						stylix.nixosModules.stylix		
					];
			};
		};
		homeConfigurations = {
			leevisuo = home-manager.lib.homeManagerConfiguration {
				inherit pkgs;
				modules = [
					./home.nix
					stylix.homeManagerModules.stylix
				];
				extraSpecialArgs = {
					nixvim = nixvim-pkg;
				};
			};
		};
	};
}
