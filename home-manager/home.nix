# ~/.config/nixpkgs/home.nix
{
  inputs,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./gnome.nix
    ./zsh.nix
    ./kitty.nix
    ./zig.nix # ./jetbrains.nix
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
          # "blender"
        ];
    };
  };

  home = {
    username = "thiago";
    homeDirectory = "/home/thiago";
    packages = with pkgs; [
      # steam
      inputs.nixvim.packages.x86_64-linux.default
      fira-code
      firefox
      hwinfo
      inkscape
      lazygit
      libinput
      luarocks
      nil
      nixpkgs-fmt
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "DroidSansMono"
        ];
      })
      nordic
      obsidian
      rclone
      sysbench
      telegram-desktop
      tor-browser
      transmission-gtk
      uget
      unzip
      whatsapp-for-linux
      wl-clipboard
      direnv
    ];
  };

  programs = {
    vscode = {
      enable = false;
      package = pkgs.vscodium.fhs;
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
