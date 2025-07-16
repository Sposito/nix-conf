{
  description = "CLion Development Shell";

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
          jetbrains.clion
        ];

        shellHook = ''
          echo "🚀 CLion Development Shell"
          echo "C/C++ IDE with CMake support"
          echo ""
          echo "Run: clion"
        '';
      };
    };
} 