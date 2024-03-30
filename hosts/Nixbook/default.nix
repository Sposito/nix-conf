# This replaces /etc/nixos/configuration.nix)

{ inputs
, lib
, config
, pkgs
, ...
}: {

  imports = [
    ./hardware-configuration.nix
    ./apple.nix
    ../common/default.nix
  ];



  networking.hostName = "Nixbook";

  programs.hyprland = {
    enable = true;
  };


  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver = {
    displayManager.sddm.wayland.enable = true;
    enable = true;
    libinput = {
      enable = true;
      touchpad.clickMethod = "clickfinger";
    };
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
    hwinfo
    libinput
  ];

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

  system.stateVersion = "23.11";
}
