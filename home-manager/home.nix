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
      boxbuddy
      direnv
      distrobox
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
    systemd.user.services.librespot-connect = {
    Unit = {
      Description = "Librespot (Spotify Connect) bound to LAN interface";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.librespot}/bin/librespot \
        --name LS-TEST \
        --backend pulseaudio \
        --device default \
        --bitrate 320 \
        --disable-audio-cache \
        --enable-volume-normalisation \
        --initial-volume 75 \
        --zeroconf-port 17005";
      Restart = "on-failure";
      BindToDevice = "wlp7s0"; # Force binding to LAN interface
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.startServices = "sd-switch"; # Nicely reload system units when changing configs
  home.file.".gitconfig-lunaria".text = ''
    [user]
      name = Thiago Sposito
      email = git@sposito.ch
  '';
  home.stateVersion = "24.05";
}
