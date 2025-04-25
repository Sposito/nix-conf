{
  description = "LuaJIT Macbook Pro Fan Controller daemon";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.fan-daemon = pkgs.stdenv.mkDerivation {
          pname = "fan-daemon";
          version = "0.1.0";

          src = ./fan-control.lua;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/bin/fan-control.lua
            makeWrapper ${pkgs.luajit}/bin/luajit $out/bin/fan-daemon \
              --add-flags "$out/bin/fan-control.lua"
          '';
        };

        nixosModules.fan-daemon = { config, lib, pkgs, ... }: {
          systemd.services.fan-daemon = {
            description = "LuaJIT Fan Control Daemon";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${self.packages.${system}.fan-daemon}/bin/fan-daemon";
              Restart = "always";
              RestartSec = 5;
              StandardOutput = "journal";
              StandardError = "journal";
            };
          };
        };
      });
}
