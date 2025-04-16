{ pkgs, ... }: {

  imports = [
    ../common/default.nix
    ./apple.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Nixbook";

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  services = {
    xserver.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    libinput = {
      enable = true;
      touchpad.clickMethod = "clickfinger";
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    exfat
    gcsfuse
    git
    home-manager
    hwinfo
    libinput
    neovim
    nil
    nixpkgs-fmt
    rclone
    wget
  ];

  system.stateVersion = "23.11";
}
