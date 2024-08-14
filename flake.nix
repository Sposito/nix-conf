{
  description = "My personal NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
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
    , nixpkgs-unstable
    , home-manager
    , vscode-extensions
    , vs-extensions-pkgs
    , flake-utils
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      # NixOS configuration entrypoint
      # Available through 'sudo nixos-rebuild switch --flake .#Nixbook'
      nixosConfigurations = {
        Nixbook = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/Nixbook ];
        };
        Nixstation = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/Nixstation ];
        };
      };

      # Available through 'home-manager switch --flake .#Nixbook@thiago'
      homeConfigurations = {
        "thiago@Nixbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };

          modules = [ ./home-manager/home.nix ];
        };
        "thiago@Nixstation" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };

          modules = [ ./home-manager/home.nix ];
        };

      };
    };
}
