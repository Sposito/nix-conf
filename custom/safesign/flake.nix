
{
  description = "Nix flake for SafeSign Identity Client 4.1.0.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { 
        inherit system; 
        config = { allowUnfree = true; };
      };

      # Basic derivation that extracts the deb file
      safesignUnwrapped = pkgs.stdenv.mkDerivation {
        pname = "safesignidentityclient-unwrapped";
        version = "4.1.0.0";

        src = pkgs.fetchurl {
          url = "https://assets.ctfassets.net/zuadwp3l2xby/4Bkz3q3wXPJBxsCz4TnA6q/bb16747e0e1dc0df4239dc16064ed420/SafeSign_IC_Standard_Linux_4.1.0.0-AET.000_ub2204_x86_64.deb";
          sha256 = "1kv2kv9d5r1pfkjk8ddshiql7s7hnwxpqf5j32bll1xy71fkz2ls";
        };

        nativeBuildInputs = [ pkgs.dpkg ];

        unpackPhase = ''
          dpkg-deb -x $src .
        '';

        installPhase = ''
          mkdir -p $out
          cp -r usr/* $out/
        '';

        meta = with pkgs.lib; {
          description = "Smart card PKCS#11 provider and token manager (unwrapped)";
          homepage = "https://certificaat.kpn.com/installatie-en-gebruik/installatie/pas-usb-stick/linux/";
          license = licenses.unfreeRedistributable; # Custom license, not OSI approved
          platforms = platforms.linux;
          maintainers = with maintainers; [ ];
        };
      };

      # Create an FHS environment with all the necessary libraries
      safesignWrapper = pkgs.buildFHSUserEnv {
        name = "safesign";
        targetPkgs = pkgs: with pkgs; [
          # Required system libraries
          glib
          gtk3
          pcsclite
          openssl
          gdbm
          xorg.libSM
          xorg.libX11
          xorg.libXxf86vm
          cairo
          pango
          gdk-pixbuf
          at-spi2-core

          # wxWidgets libraries
          wxGTK30

          # The unwrapped package
          safesignUnwrapped
        ];

        # Set up the run script to launch the tokenadmin program
        runScript = "tokenadmin";

        # Add additional environment variables if needed
        extraInstallCommands = ''
          # Create a .desktop file
          mkdir -p $out/share/applications
          cat > $out/share/applications/safesign-tokenadmin.desktop << EOF
          [Desktop Entry]
          Name=SafeSign Token Admin
          Comment=KPN SafeSign Identity Client
          Exec=$out/bin/safesign
          Icon=${safesignUnwrapped}/share/pixmaps/tokenadmin.png
          Terminal=false
          Type=Application
          Categories=Office;Security;
          EOF
        '';
      };

      # Additional wrapper for pkcs11 module 
      safesignidentityclient = pkgs.stdenv.mkDerivation {
        pname = "safesignidentityclient";
        version = "4.1.0.0";

        # No sources, we just need to create wrapper scripts
        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin $out/lib $out/share

          # Create a symlink to the FHS environment wrapper
          ln -s ${safesignWrapper}/bin/safesign $out/bin/tokenadmin

          # Link the PKCS#11 module
          ln -s ${safesignUnwrapped}/lib/libaetpkss.so $out/lib/
          ln -s ${safesignUnwrapped}/lib/libaetpkss.so.3 $out/lib/
          ln -s ${safesignUnwrapped}/lib/libaetpkss.so.3.9.21 $out/lib/
          ln -s ${safesignUnwrapped}/lib/libaetpkss.so.3.9.21.1 $out/lib/

          # Copy over desktop file
          mkdir -p $out/share/applications
          cp ${safesignWrapper}/share/applications/safesign-tokenadmin.desktop $out/share/applications/
        '';

        meta = with pkgs.lib; {
          description = "Smart card PKCS#11 provider and token manager";
          homepage = "https://certificaat.kpn.com/installatie-en-gebruik/installatie/pas-usb-stick/linux/";
          license = licenses.unfreeRedistributable; # Custom license, not OSI approved
          platforms = platforms.linux;
          maintainers = with maintainers; [ ];
        };
      };
    in {
      packages = {
        default = safesignidentityclient;
        unwrapped = safesignUnwrapped;
        fhsEnv = safesignWrapper;
      };
    }
  );
}
