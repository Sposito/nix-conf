{
  inputs,
  ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
in
{
  home.packages = with unstable; [
    windsurf
    code-cursor
  ];
}
