{
  description = "Code Cursor Development Shell";

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
          code-cursor
        ];

        shellHook = ''
          echo "🤖 Code Cursor Development Shell"
          echo "AI-powered code editor"
          echo ""
          echo "Run: code-cursor"
        '';
      };
    };
}
