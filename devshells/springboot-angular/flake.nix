{
  description = "Dev environment for Spring Boot + Angular + IntelliJ IDEA Ultimate (Java 21)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnauthenticated = true; # optional for IntelliJ binaries
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            openjdk21
            maven
            spring-boot-cli
            nodejs
            pnpm
            jetbrains.idea-ultimate
          ];

          shellHook = ''
            export JAVA_HOME=${pkgs.openjdk21.home}
            echo "✅ Spring Boot + Angular Dev Environment (Java 21, IntelliJ Ultimate)"
            echo "👉 IntelliJ IDEA Ultimate is launching..."

            # Launch IntelliJ automatically (if not already running)
            if ! pgrep -x "idea-ultimate" > /dev/null; then
              nohup idea-ultimate . > /dev/null 2>&1 &
            fi
          '';
        };
      }
    );
}
