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


  services.libinput = {
    enable = true;
    touchpad.clickMethod = "clickfinger";
  };

  services.displayManager.sddm.wayland.enable = true;

  services.xserver.enable = true;


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
