{
  inputs,
  ...
}:
{
  home.packages = with inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; [
    bambu-studio
    freecad
    orca-slicer
    openscad-lsp
    openscad-unstable
  ];
}
