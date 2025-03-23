{ inputs
, pkgs
, ...
}:
{
  home.packages = with pkgs; [
    jetbrains.clion
    jetbrains.pycharm-professional
    jetbrains.goland
    jetbrains.idea-ultimate
  ];
}
