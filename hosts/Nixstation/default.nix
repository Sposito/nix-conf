{ inputs
, lib
, config
, pkgs
, ...
}: {

  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../common/network.nix
    ../common/screen.nix
    ../common/nvidia/default.nix
    ../common/podman/default.nix
  ];

  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Sao_Paulo";

  services.xserver.xkb = {  # Configure keymap in X11
    layout = "us";
    variant = "alt-intl";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  
  
  environment.systemPackages = with pkgs; [
    wget
    python3
    git
    exfat
    nil
    nixpkgs-fmt
    home-manager
    rclone
    gcsfuse
    hwinfo
    libinput
    gnome3.gnome-tweaks
    gnome3.gnome-session
    zsh
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;
     # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true; 
  services.displayManager.autoLogin.enable = false;
 # services.displayManager.autoLogin.user = "thiago";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome3.gnome-session}/bin/gnome-session";
  services.xrdp.openFirewall = true;
  
  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 3389 ];
    allowedUDPPorts = [ 3389 ];
  };


  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;




  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };





    
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
  };
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemuOvmf = true;
  # };
  
  programs.virt-manager.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
