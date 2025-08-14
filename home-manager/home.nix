{ inputs
, lib
, pkgs
, config
, ...
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
    ./vim.nix
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
      ghostty
      inkscape
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
      ripgrep
      shfmt
      spotify-qt
      librespot
      statix
      stylua
      sysbench
      transmission_4-gtk
      uget
      unzip
    ];

  };

  programs = {
    vscode.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "sposito.thiago@gmail.com";
      userName = "Thiago Sposito";
  includes = [
    {
      condition = "gitdir:/home/thiago/Projects/lunaria/";
      path = "${config.home.homeDirectory}/.gitconfig-lunaria";
    }
  ];

    };
    home-manager.enable = true;
  };
  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs
  home.file.".gitconfig-lunaria".text = ''
    [user]
      name = Thiago Sposito
      email = git@sposito.ch
  '';
  home.stateVersion = "24.05";
}
