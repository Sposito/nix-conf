{
  description = "LuaJIT + Luarocks + C Dev Environment with SQLite3 and lsqlite3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { nixpkgs }: {
    devShells = {
      x86_64-linux = nixpkgs.lib.mkShell {
        buildInputs = with nixpkgs; [
          luajit # LuaJIT for Lua execution
          luarocks # Luarocks for managing Lua modules
          sqlite # SQLite3 library
          gcc # GCC for C development
          pkg-config # Needed for compiling C libraries
          make # Make for compiling C projects
          # Add more C libraries as necessary
        ];

        # Install lsqlite3 through Luarocks
        shellHook = ''
          echo "Setting up LuaJIT with Luarocks, SQLite3, and C development tools"
          
          # Export LUA_PATH and LUA_CPATH
          export LUA_PATH="$LUA_PATH;./?.lua"
          export LUA_CPATH="$LUA_CPATH;./?.so"

          # Install the lsqlite3 Lua module via Luarocks if not installed
          if ! luarocks show lsqlite3 >/dev/null 2>&1; then
            luarocks install lsqlite3
          fi
        '';
      };
    };
  };
}

