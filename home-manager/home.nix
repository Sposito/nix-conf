# ~/.config/nixpkgs/home.nix
{
  inputs,
  lib,
  pkgs,
  networking,
  ...
}:
{

  imports = [
    ./ai-editors.nix
    ./game-emu.nix
    ./gnome.nix
    ./hydra.nix
    ./jetbrains.nix
    ./kitty.nix
    ./polymc.nix
    ./zsh.nix
    # (lib.mkIf (lib.strings.hasInfix "Nixbook" (networking.hostName)) ./hyprland.nix)
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
      direnv
      fira-code
      firefox
      hwinfo
      inkscape
      inputs.nixvim.packages.x86_64-linux.default
      lazygit
      libinput
      luarocks
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "DroidSansMono"
        ];
      })
      nil
      nixpkgs-fmt
      nordic
      obsidian
      rclone
      sysbench
      transmission_4-gtk
      uget
      unzip
      whatsapp-for-linux
      wl-clipboard
    ];
  };

  programs = {
    vscode = {
      enable = true;

      package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (_oldAttrs: rec {
        src = builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
          sha256 = "1nbdyif2j6jbbd4c0nczr89mvd2d60w8q3wj0wv9ycksikhswvy5";
        };
        version = "latest";
      });
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
