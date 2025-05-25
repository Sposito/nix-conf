{ inputs, lib, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "windsurf"
        "code-cursor"
      ];
  };
in
{
  home.packages = with nixpkgs-unstable; [
    windsurf
    code-cursor
  ];
}
