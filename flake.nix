{
	description = "My flake";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix = {
			url = "github:danth/stylix/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stormy.url = "github:ashish0kumar/stormy";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix,  ... }@inputs:
		let
		lib = nixpkgs.lib;
	system = "x86_64-linux"; 
	pkgs = nixpkgs.legacyPackages.${system};
	unstable = nixpkgs-unstable.legacyPackages.${system};
	in {
		nixosConfigurations = {
			nixos = lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs stylix unstable;
				};
				modules = [
					./configuration.nix
					stylix.nixosModules.stylix		
					home-manager.nixosModules.home-manager
				];
			};
		};
	};
}
