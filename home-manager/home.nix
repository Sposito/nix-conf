# ~/.config/nixpkgs/home.nix
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
  };
in
{

  imports = [
    ./game.nix
    ./gnome.nix
    ./kitty.nix
    ./maker.nix
    ./zsh.nix
  ];

  nixpkgs = {
    overlays = [

    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
          "steam-original"
          "steam-run"
          "steamtinkerlaunch"
        ];
    };
  };

  home = {
    username = "thiago";
    #   fonts.packages = with pkgs; [
    # nerd-fonts.fira-code
    # nerd-fonts.droid-sans-mono
    #];
    homeDirectory = "/home/thiago";
    packages = with pkgs; [
      direnv
      fira-code
      firefox
      hwinfo
      inkscape
      inputs.nixvim.packages.x86_64-linux.default
      keymapp
      lazygit
      libinput
      luarocks
      nil
      nixpkgs-fmt
      nordic
      obsidian
      python3
      python3Packages.pip
      rclone
      sysbench
      transmission_4-gtk
      uget
      unzip
      whatsapp-for-linux
    ];

  };

  programs = {
    vscode.enable = true;
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
