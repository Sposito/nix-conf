{ pkgs, ... }: {

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

  services = {
    libinput = {
      displayManager.sddm.wayland.enable = true;
      enable = true;
      touchpad.clickMethod = "clickfinger";
    };
    xserver.enable = true;
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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.11";
}
