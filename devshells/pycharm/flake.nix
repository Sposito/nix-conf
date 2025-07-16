{
  description = "PyCharm Professional Development Shell";

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
          jetbrains.pycharm-professional
        ];

        shellHook = ''
          echo "🐍 PyCharm Professional Development Shell"
          echo "Python IDE with advanced features"
          echo ""
          echo "Run: pycharm-professional"
        '';
      };
    };
} 