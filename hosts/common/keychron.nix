{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    xkb = {
      layout = "custom-br";
      variant = "";
      model = "pc105";
      extraLayouts = {
        custom-br = {
          description = "US Custom BR (altgr-intl + ç)";
          languages = [ "eng" ];
          symbolsFile = pkgs.writeText "custom-br" ''
            partial alphanumeric_keys
            xkb_symbols "basic" {
              include "us(altgr-intl)"
              name[Group1]= "US Custom BR (altgr-intl + ç)";
              key <AC03> {
                type= "ALPHABETIC",
                symbols[Group1]= [ c, C, ccedilla, Ccedilla ]
              };
            };
          '';
        };
      };
    };

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;
  };
}
