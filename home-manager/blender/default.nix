{ inputs, lib, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "blender"
      ];
  };
in
{
  home.packages = with nixpkgs-unstable; [
    (blender.override {
      cudaSupport = true;
    })
  ];
}