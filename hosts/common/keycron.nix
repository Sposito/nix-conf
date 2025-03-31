{ pkgs, ... }:
let
  customXkb = pkgs.writeTextDir "xkb/symbols/us-custom-br" ''
    default partial alphanumeric_keys
    xkb_symbols "us-custom-br" {
      include "us(altgr-intl)"
      name[Group1]= "US Custom BR (altgr-intl + ç)";
      key <AC03> {
        type= "ALPHABETIC",
        symbols[Group1]= [ c, C, ccedilla, Ccedilla ]
      };
    };
  '';

  customXkbMerged = pkgs.symlinkJoin {
    name = "custom-xkb-merged";
    paths = [
      customXkb
      pkgs.xkeyboard_config
    ];
  };
in
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us-custom-br";
      dir = "${customXkbMerged}/xkb";
    };
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;
  };
}
