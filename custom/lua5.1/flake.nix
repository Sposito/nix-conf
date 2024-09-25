{
  description = "A Nix flake to build Lua 5.1.5 from source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = {
      lua5.1 = nixpkgs.lib.mkDerivation rec {
        pname = "lua";
        version = "5.1.5";

        src = builtins.fetchurl {
          url = "https://www.lua.org/ftp/lua-5.1.5.tar.gz";
          sha256 = "sha256-2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333=";
        };

        nativeBuildInputs = [ nixpkgs.buildPackages.gnumake ];
        buildInputs = [ nixpkgs.readline ];

        buildPhase = ''
          make linux
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib $out/include
          cp src/lua src/luac $out/bin/
          cp src/liblua.a $out/lib/
          cp -r src/*.h $out/include/
        '';

        meta = with nixpkgs.lib; {
          description = "Lua 5.1.5, an embeddable scripting language";
          license = licenses.mit;
          platforms = platforms.linux;
          maintainers = [ maintainers.self ];
        };
      };
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.lua5_1;
    apps.default = {
      lua5_1 = {
        type = "app";
        program = "${self.packages.x86_64-linux.lua5_1}/bin/lua";
      };
    };
  };
}

