# This replaces /etc/nixos/configuration.nix)

{ inputs
, lib
, config
, pkgs
, ...
}: {

  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [ ];

    config.allowUnfree = true;
  };

  networking.hostName = "Nixbook";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  services.xserver.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6 = {
  #   enable = true;
  #   enableQt5Integration = true;
  # };

  programs.hyprland= {
    enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  
  # services.xserver.desktopManager.plasma6.enable = true;
  services.xserver.libinput.enable = true;

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc =
    lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    exfat
    neovim
    nil
    nixpkgs-fmt
    home-manager
    rclone
    gcsfuse
    kdePackages.qtwebengine

  ];

  boot.loader.systemd-boot.enable = true;

  users.users = {
    thiago = {
      isNormalUser = true;
      description = "Thiago Sposito";
      extraGroups = [ "networkmanager" "wheel" ];
      
      packages = with pkgs; [
        steam
        nordic
        nmap
        vim
        vscode
        neovim
        sysbench
        firefox
        obsidian
        whatsapp-for-linux
        inkscape
        blender
        lapce
        fira-code
        waybar
	kitty
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
