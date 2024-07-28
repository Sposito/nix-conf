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

  nixpkgs = {
    overlays = [
      (import ./blender.nix).overlays.default
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
      fira-code
      nixpkgs-fmt
      rclone
      lilipod
      distrobox

      # Add Blender packages here
      (import ./blender.nix).packages.x86_64-linux.blender_4_1
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
