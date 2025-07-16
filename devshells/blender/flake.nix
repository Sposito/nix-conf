{
  description = "Blender with CUDA Development Shell";

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
          (blender.override {
            cudaSupport = true;
          })
        ];

        shellHook = ''
          echo "🎨 Blender with CUDA Development Shell"
          echo "CUDA support enabled for GPU rendering"
          echo ""
          echo "Run: blender"
        '';
      };
    };
} 