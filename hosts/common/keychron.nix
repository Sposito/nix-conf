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
          description = "US Custom BR (apostrophe + c → ç)";
          languages = [ "eng" ];
          symbolsFile = pkgs.writeText "custom-br" ''
            partial alphanumeric_keys
            xkb_symbols "basic" {
              include "us(altgr-intl)"
              name[Group1]= "US Custom BR (apostrophe + c → ç)";

              // Override the apostrophe key to be a fake dead key
              key <AC10> {
                type= "FOUR_LEVEL",
                symbols[Group1]= [ dead_acute, dead_acute, dead_acute, dead_acute ]
              };

              // Redefine the c key to output ç when used after apostrophe
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
