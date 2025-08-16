{ pkgs, ... }: {

  imports = [
    ../common/default.nix
    ./apple.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "Nixbook";

  users.users.thiago.extraGroups = [ "input" ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
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

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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
    pulseaudio
    networkmanagerapplet
    brightnessctl
    playerctl
  ];

  system.stateVersion = "23.11";
}
