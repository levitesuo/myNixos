{
	description = "My flake";

	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.05";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix = {
			url = "github:danth/stylix/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
	};

	outputs = { self, nixpkgs, home-manager, stylix, android-nixpkgs, ... }:
		let
		lib = nixpkgs.lib;
	system = "x86_64-linux"; 
	pkgs = nixpkgs.legacyPackages.${system};
	in {
		nixosConfigurations = {
			nixos = lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit stylix;
					inherit android-nixpkgs;
				};
				modules = [ 
					{ nixpkgs.overlays = [ android-nixpkgs.overlays.default ]; }
					./configuration.nix  
					stylix.nixosModules.stylix		
					home-manager.nixosModules.home-manager
				];
			};
		};
	};
}
