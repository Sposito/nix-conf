{
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (import (
      builtins.fetchTarball {
        url = "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz";
        sha256 = "0c1b7jniky68pn6gh17ssmv5ll8p37sdg92kbhafzhvja1gva4m1";
      }
    )).overlay
  ];

  home.packages = with pkgs; [ polymc ];
}
