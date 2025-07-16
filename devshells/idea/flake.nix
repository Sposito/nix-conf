{
  description = "IntelliJ IDEA Ultimate Development Shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          jetbrains.idea-ultimate
        ];

        shellHook = ''
          echo "☕ IntelliJ IDEA Ultimate Development Shell"
          echo "General-purpose IDE for Java and more"
          echo ""
          echo "Run: idea-ultimate"
        '';
      };
    };
} 