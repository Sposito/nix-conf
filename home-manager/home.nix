# ~/.config/nixpkgs/home.nix
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland
    ./kitty.nix
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
    homeDirectory = "/home/thiago";
    packages = with pkgs; [
      fira-code
      firefox
      hwinfo
      inkscape
      inputs.nixvim.packages.x86_64-linux.default
      lazygit
      libinput
      luarocks
      nil
      nixpkgs-fmt
      nordic
      obsidian
      rclone
      sysbench
      nerd-fonts.gohufont
      tor-browser
      transmission_4-qt
      uget
      unzip
      kanshi
      whatsapp-for-linux
      wl-clipboard
      direnv
      swaybg
    ];
  };

  programs = {
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
