# This replaces ~/.config/nixpkgs/home.nix)
{ inputs
, lib
, config
, pkgs
, ...
}: {
  # You can import other home-manager modules here
  imports = [
    # TODO: in the future I might want to use home-manager modules from other flakes
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

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
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "thiago";
    homeDirectory = "/home/thiago";
    packages = with pkgs;[
      nil
      steam
      nordic
      sysbench
      firefox
      obsidian
      whatsapp-for-linux
      inkscape
      blender
      fira-code
      kitty
      nixpkgs-fmt
      rclone
    ];
  };



  programs = {
    # NEOVIM
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    #GIT
    git = {
      enable = true;
      lfs.enable = true;
      userEmail = "sposito.thiago@gmail.com";
      userName = "Thiago Sposito";
    };

    #VS CODE
    vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        bbenoist.nix
        jnoortheen.nix-ide
        arcticicestudio.nord-visual-studio-code
      ];


      userSettings = {
        "user.colorTheme" = "Nord";
        "workbench.colorTheme" = "Nord";
        "terminal.integrated.fontFamily" = "Hack";
      };
    };

    home-manager.enable = true;
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";


  home.stateVersion = "23.11";
}
