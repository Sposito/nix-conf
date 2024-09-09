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
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Sao_Paulo";

  services.xserver.xkb = {
    # Configure keymap in X11
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
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    gnome3.gnome-tweaks
    gnome3.gnome-session
    gnomeExtensions.pop-shell
    cudatoolkit
    act
    vmware-workstation
    xorg.xauth
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
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "thiago";
  programs.dconf.enable = true;


  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-remote-desktop";
  services.xrdp.openFirewall = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 3389 ];
    allowedUDPPorts = [ 3389 ];

    extraCommands = ''
      # NAT rule for sharing internet over enp129s0f1
      iptables -t nat -A POSTROUTING -o wlp4s0 -j MASQUERADE
      iptables -A FORWARD -i enp129s0f1 -o wlp4s0 -j ACCEPT
      iptables -A FORWARD -i wlp4s0 -o enp129s0f1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    '';
  };
    networking.interfaces.enp129s0f1.useDHCP = true; # Add your custom config here
    networking.interfaces.enp129s0f1.ipv4.addresses = [ {
      address = "192.168.100.1";
      prefixLength = 24;
    } ];
  networking.networkmanager.unmanaged = [ "interface-name:enp129s0f1" ];

  networking = {
    nat = {
      enable = true;
      externalInterface = "wlp4s0";  # Your WiFi interface
      internalInterfaces = [ "enp129s0f1" ];  # Your wired interface
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
  };

  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=enp129s0f1
      dhcp-range=192.168.100.50,192.168.100.150,24h
      dns-forward-max=1000
    '';
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.sane.enable = true;


  services.udev.packages = [ pkgs.utsushi ];
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.vmware.host.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.package = pkgs.qemu_full;
  };


  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "intel_iommu=on"
    "iommu=pt"
  ];
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemuOvmf = true;
  # };

  programs.virt-manager.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
