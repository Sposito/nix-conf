{
  description = "Zig Development Shell";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs-unstable }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          zig
        ];

        shellHook = ''
          echo "⚡ Zig Development Shell"
          echo "Zig version: $(zig version)"
          echo ""
          echo "Run: zig"
        '';
      };
    };
} 