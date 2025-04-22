{
  description = "Machine-bound keygen script (safe version)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "machine-key-script";

          src = ./.;

          installPhase = ''
            mkdir -p $out/bin
            cp generate-key.sh $out/bin/generate-key.sh
            chmod +x $out/bin/generate-key.sh
          '';
        };
      });
}
