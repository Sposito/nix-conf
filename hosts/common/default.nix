{ inputs
, lib
, config
, pkgs
, ghostty
, ...
}:
{

  imports = [ ./users/thiago/default.nix ];

  boot.loader.systemd-boot.enable = true;
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/Sao_Paulo";

  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;

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
  environment = {
    shells = with pkgs; [ zsh ];
    etc = lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;
    systemPackages = with pkgs; [
      wget
      git
      exfat
      home-manager
      gcsfuse
      file
    ];
  };

}
