# ~/.config/nixpkgs/home.nix
{ inputs
, lib
, pkgs
, ...
}:
{

  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./jetbrains.nix
    ./kitty.nix
    ./polymc.nix
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
      transmission_4-gtk
      uget
      unzip
      whatsapp-for-linux
      wl-clipboard
      direnv
    ];
  };

  programs = {
    vscode = {
      enable = true;

      package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (_oldAttrs: rec {
        src = builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
          sha256 = "1qi22w461nb2hjn38qhh9m9sdnnczfradq2c7ck2kadl2yn3wfx7";
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
