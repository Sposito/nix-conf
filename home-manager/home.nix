# ~/.config/nixpkgs/home.nix
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
    ./zig.nix
    ./jetbrains.nix
  ];

  nixpkgs = {
    overlays = [

    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
        "blender"
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
      telegram-desktop
      inkscape
      fira-code
      nixpkgs-fmt
      rclone
      lilipod
      distrobox
      uget
      tor-browser
      microsoft-edge
      tor-browser
      # blender
      # blender-bin  # Add blender-bin to the list of installed packages
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
