{
  description = "My personal NixOS Config";

  inputs = {
    nixpkgs.url =  "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
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
          # > Our main nixos configuration file <
          modules = [
            ./nixos/configuration.nix 
    #        ./nixos/apple
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager switch --flake .#Nixbook@thiago'
      homeConfigurations = {
        "thiago@Nixbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          # > Main home-manager configuration file <
          modules = [ ./home-manager/home.nix ];
        };
      };
    };
}
