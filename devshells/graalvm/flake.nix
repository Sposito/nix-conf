{
  description = "Dev shell with GraalVM, IDEA Ultimate, Maven from unstable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # or your stable
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        unstablePkgs = import unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            unstablePkgs.graalvm-ce
            unstablePkgs.jetbrains.idea-ultimate
            unstablePkgs.maven
          ];
        };
      }
    );
}
