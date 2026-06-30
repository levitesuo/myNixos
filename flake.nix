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
	unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
	in {
		nixosConfigurations = {
			workstation = lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs stylix unstable;
					hostname = "ls-workstation";
				};
				modules = [
					./configuration.nix
					./hosts/workstation/hardware-configuration.nix
					stylix.nixosModules.stylix
					home-manager.nixosModules.home-manager
				];
			};
			laptop = lib.nixosSystem {
				inherit system;
				specialArgs = {
					inherit inputs stylix unstable;
					hostname = "ls-laptop";
				};
				modules = [
					./configuration.nix
					./hosts/laptop/hardware-configuration.nix
					./hosts/laptop/gpu.nix
					./pin-flake-inputs.nix
					stylix.nixosModules.stylix
					home-manager.nixosModules.home-manager
				];
			};
		};
	};
}
