{ inputs, lib, pkgs, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
  };
in
{
    nixpkgs.overlays = [
    (import (
      builtins.fetchTarball {
        url = "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz";
        sha256 = "0c1b7jniky68pn6gh17ssmv5ll8p37sdg92kbhafzhvja1gva4m1";
      }
    )).overlay
  ];

  home.packages = with nixpkgs-unstable; [
    torzu
    heroic
    hydralauncher
    polymc
  ];
}
