{
  description = "PC Monitor tool";

#  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.stdenv.mkDerivation {
            pname = "pc-monitor";
            version = "0.0.1";

            src = ./.;

            buildInputs = with pkgs; [
             gcc
             lm_sensors
             sqlite
             python3
             ];

            buildPhase = ''
              gcc -Wall -Wextra -pedantic -o pc-monitor main.c -lsensors -lsqlite3
            '';

            checkPhase = ''
              python tests.py
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp pc-monitor $out/bin/
            '';
          };
        });
    };
}
