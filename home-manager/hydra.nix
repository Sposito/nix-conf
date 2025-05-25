{ inputs
, ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
in
{
  home.packages = [
    unstable.hydralauncher
  ];
}
