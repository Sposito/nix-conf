{
  description = "My personal NixOS Config";

  inputs = {
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:sposito/nixvim";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };

    ghostty.url = "github:ghostty-org/ghostty";

    flake-utils.follows = "vscode-extensions/flake-utils";
    vs-extensions-pkgs.follows = "vscode-extensions/nixpkgs";

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

          modules = [ ./home-manager/home.nix ];
        };
        "thiago@Nixstation" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
          };

          modules = [ ./home-manager/home.nix ];
        };

      };

    apps.x86_64-linux.disko-install = {
      type = "app";
      program = "${inputs.disko.packages.x86_64-linux.disko}/bin/disko-install";
    };
    };
}
