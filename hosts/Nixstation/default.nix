{ inputs
, lib
, config
, pkgs
, ...
}: {

  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../common/nvidia/default.nix
    ../common/podman/default.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "Nixstation";

  environment.systemPackages = with pkgs; [
    wget
    python3
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
    gnome3.gnome-tweaks

  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;
     # Open ports in the firewall for Steam Local Network Game Transfers
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/Sao_Paulo";
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.samba.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };


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

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "thiago";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
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
