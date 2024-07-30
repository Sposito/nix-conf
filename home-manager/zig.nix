{ inputs
,pkgs
, ... 
}: let
unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
in
{
  home.packages = with pkgs; [
    unstable.zig
  ];
}
