{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./users/thiago/default.nix ];

  boot.loader.systemd-boot.enable = true;
  environment = {
    shells = with pkgs; [ zsh ];
    etc = lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    }) config.nix.registry;
    systemPackages = with pkgs; [
      exfat
      file
      gcsfuse
      git
      gnupg
      home-manager
      keymapp
      opensc
      pciutils
      pcsc-safenet
      pcsctools
      pkcs11helper
      sops
      wget
      zsa-udev-rules
    ];
  };
  hardware.keyboard.zsa.enable = true;
  networking.networkmanager.enable = true;
  nix = {
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );

    nixPath = [ "/etc/nix/path" ];

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  services.pcscd.enable = true;
  time.timeZone = "America/Sao_Paulo";
  users.defaultUserShell = pkgs.zsh;
}
