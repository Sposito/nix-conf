{
  description = "A free and open source 3D creation suite (upstream binaries)";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:

    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      };

      mkBlender = { pname, version, src }:
        with pkgs;

        let
          libs =
            [ wayland libdecor xorg.libX11 xorg.libXi xorg.libXxf86vm xorg.libXfixes xorg.libXrender libxkbcommon libGLU libglvnd numactl SDL2 libdrm ocl-icd stdenv.cc.cc.lib openal ]
            ++ lib.optionals (lib.versionAtLeast version "3.5") [ xorg.libSM xorg.libICE zlib ];
        in

        stdenv.mkDerivation rec {
          inherit pname version src;

          buildInputs = [ makeWrapper ];

          preUnpack =
            ''
              mkdir -p $out/libexec
              cd $out/libexec
            '';

          installPhase =
            ''
              cd $out/libexec
              mv blender-* blender

              mkdir -p $out/share/applications
              mv ./blender/blender.desktop $out/share/applications/blender.desktop

              mkdir $out/bin

              makeWrapper $out/libexec/blender/blender $out/bin/blender \
                --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${lib.makeLibraryPath libs}

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                blender/blender

              patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
                $out/libexec/blender/*/python/bin/python3*
            '';

          meta.mainProgram = "blender";
        };

      mkTest = { blender }:
        pkgs.runCommand "blender-test" { buildInputs = [ blender ]; }
          ''
            blender --version
            touch $out
          '';

    in {

      overlays.default = final: prev: {
        blender_4_1 = mkBlender {
          pname = "blender-bin";
          version = "4.1.1";
          src = import <nix/fetchurl.nix> {
            url = "https://ftp.nluug.nl/pub/graphics/blender/release/Blender4.1/blender-4.1.1-linux-x64.tar.xz";
            hash = "sha256-qy6j/pkWAaXmvSzaeG7KqRnAs54FUOWZeLXUAnDCYNM=";
          };
        };
      };

      lib.mkBlender = mkBlender;

      packages.x86_64-linux = rec {
        inherit (pkgs)

          blender_4_1;
        default = blender_4_1;
      };

      checks.x86_64-linux = {
        blender_4_1  = mkTest { blender = self.packages.x86_64-linux.blender_4_1; };
      };

    };
}