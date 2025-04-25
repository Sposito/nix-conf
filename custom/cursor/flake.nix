{
  description = "Flake for Cursor AppImage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        appImageUrl = "https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/x64/Cursor-0.48.8-x86_64.AppImage";
        appImageName = "Cursor-0.48.8-x86_64.AppImage";

        cursor = pkgs.appimageTools.wrapType2 {
          name = "cursor";
          src = pkgs.fetchurl {
            url = appImageUrl;
            sha256 = "14bh8xa0zl78vcprw1zd6ldklaqhry1jv0lmlq8yblndbh9b16gz";
          };
        };

        desktopFile = pkgs.makeDesktopItem {
          name = "cursor";
          exec = "cursor";
          icon = "cursor";
          desktopName = "Cursor";
          genericName = "Code Editor";
          categories = [ "Development" "IDE" ];
          comment = "The AI IDE";
        };
      in
      {
        packages.cursor = pkgs.buildEnv {
          name = "cursor-env";
          paths = [ cursor desktopFile ];
        };

        apps.default = {
          type = "app";
          program = "${cursor}/bin/cursor";
        };

        defaultPackage = self.packages.${system}.cursor;
      }
    );
}
