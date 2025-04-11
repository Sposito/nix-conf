{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "nixos-anywhere-test-env";

  packages = with pkgs; [
    nix
    nixos-anywhere
    openssh
    sshpass
    qemu_full
    wget
  ];

  shellHook = ''
    echo "Entered NixOS Anywhere Test Environment."
    echo "Alpine image will be downloaded if needed."
    echo "Run ./install_test.sh to start the QEMU VM and run the installation."
  '';
}
