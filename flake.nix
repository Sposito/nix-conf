{
  description = "NixOS Config v0.0.0";


  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";


    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.05";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.follows = "vscode-extensions/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    vs-extensions-pkgs.follows = "vscode-extensions/nixpkgs";

  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      # NixOS configuration entrypoint
      # Available through 'sudo nixos-rebuild switch --flake .#Nixbook'
      nixosConfigurations = {
        Nixbook = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/Nixbook
            ./hosts/Nixbook/disko.nix
            inputs.disko.nixosModules.disko
          ];
        };
        Nixstation = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/Nixstation ];
        };
      };

      # Available through 'home-manager switch --flake .#Nixbook@thiago'
      homeConfigurations = {
        "thiago@Nixbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
          };

          modules = [
            ./home-manager/home.nix
            { custom.sessionType = "wayland"; }
          ];
        };
        "thiago@Nixstation" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
          };

          modules = [
            ./home-manager/home.nix
            { custom.sessionType = "x11"; }
          ];
        };

      };

      apps.x86_64-linux.disko-install = {
        type = "app";
        program = "${inputs.disko.packages.x86_64-linux.disko}/bin/disko-install";
      };

      devShells.x86_64-linux = { };
    };
}
