{
  description = "Dev environment for Python (PyCharm, Jupyter, OpenGL, matplotlib, numpy, PIL)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs }:
    {
      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.numpy
            python3Packages.pillow
            python3Packages.matplotlib
            python3Packages.jupyter

            jetbrains.pycharm-professional

            # OpenGL support
            mesa
            libGL
            libGLU
            xorg.libX11
          ];

          shellHook = ''
            echo "✅ Python Dev Environment Ready (PyCharm, Jupyter, OpenGL)"
            echo "👉 Launching PyCharm Professional..."

            if ! pgrep -x "pycharm-professional" > /dev/null; then
              nohup pycharm-professional . > /dev/null 2>&1 &
            fi
          '';
        };
    };
}
