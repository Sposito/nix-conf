# This replaces ~/.config/nixpkgs/home.nix)
{ inputs
, lib
, config
, pkgs
, ...
}: {

  imports = [

    ./gnome.nix
    ./vscode.nix
    ./zsh.nix
    ./kitty.nix
  ];
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #   localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  # };
  nixpkgs = {

    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];
    };
  };

  home = {
    username = "thiago";
    homeDirectory = "/home/thiago";
    packages = with pkgs;[
      nil
      transmission-gtk
      # steam
      nordic
      sysbench
      firefox
      obsidian
      whatsapp-for-linux
      inkscape
      blender
      fira-code
      nixpkgs-fmt
      rclone
      lilipod
      distrobox
    ];
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "sposito.thiago@gmail.com";
      userName = "Thiago Sposito";
    };

    home-manager.enable = true;
  };

  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs
  home.stateVersion = "24.05";
}
