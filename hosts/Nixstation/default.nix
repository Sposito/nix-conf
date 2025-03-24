{
  config,
  pkgs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../common/network.nix
    ../common/screen.nix
    ../common/rclone.nix
    ../common/nvidia/default.nix
  ];
  #  services.motd = {
  #      enable = true;
  #      text = ''
  #    ▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖▗▄▖▗▄▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖  ▗▖
  #    ▐▛▚▖▐▌  █   ▝▚▞▘ ▐▌     █ ▐▌ ▐▌ █    █  ▐▌ ▐▌▐▛▚▖▐▌
  #    ▐▌ ▝▜▌  █    ▐▌   ▝▀▚▖  █ ▐▛▀▜▌ █    █  ▐▌ ▐▌▐▌ ▝▜▌
  #    ▐▌  ▐▌▗▄█▄▖▗▞▘▝▚▖▗▄▄▞▘  █ ▐▌ ▐▌ █  ▗▄█▄▖▝▚▄▞▘▐▌  ▐▌
  #                                                 
  #[   Xeon E5-2650 v4 x48 ]-[   128 Gb ]-[   Nivdia RTX 3090]
  #                                ┏┳┓┓ •        ┏┓     •   
  #                                 ┃ ┣┓┓┏┓┏┓┏┓  ┗┓┏┓┏┓┏┓╋┏┓
  #                                 ┻ ┛┗┗┗┻┗┫┗┛  ┗┛┣┛┗┛┛┗┗┗┛
  #                                         ┛      ┛        
  #      '';
  #    };
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [
      # "nvidia-drm.modeset=1"
      # "intel_iommu=on"
      # "iommu=pt"
    ];
  };

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

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-session
    gnomeExtensions.pop-shell
    cudatoolkit
    act
    vmware-workstation
    xorg.xauth
    #jetbrains.gateway
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

    };

    dconf.enable = true;
    virt-manager.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.wayland = false;
      xkb = {
        layout = "us";
        variant = "alt-intl";
      };
    };
    # gnome.gnome-remote-desktop.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "thiago";

    flatpak.enable = true;

    xrdp = {
      enable = false;
      defaultWindowManager = "gnome-remote-desktop";
      openFirewall = true;
    };

    # udev.packages = [ pkgs.utsushi ];
    # printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 30;
    algorithm = "zstd";
  };

  # Open ports in the firewall.
  #networking.firewall = {
  # enable = false;
  # allowPing = true;
  # allowedTCPPorts = [ 3389 ];
  # allowedUDPPorts = [ 3389 ];

  # extraCommands = ''
  # NAT rule for sharing internet over enp5s0
  #  iptables -t nat -A POSTROUTING -o wlp4s0 -j MASQUERADE
  #  iptables -A FORWARD -i enp5s0 -o wlp4s0 -j ACCEPT
  #  iptables -A FORWARD -i wlp4s0 -o enp5s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
  #'';
  #};

  #networking.interfaces.enp5s0.useDHCP = true; # Add your custom config here
  #  networking.interfaces.enp5s0.ipv4.addresses = [
  #    {
  #     address = "192.168.1.254";
  #     prefixLength = 24;
  #    }
  #  ];
  # networking.networkmanager.unmanaged = [ "interface-name:enp5s0" ];
  # enp6s0
  #networking = {
  #nat = {
  #     enable = true;
  #     internalInterfaces = [ "enp5s0" ]; # Your wired interface
  #   };
  # };

  # boot.kernel.sysctl = {
  #   "net.ipv4.ip_forward" = "1";
  # };

  # services.dnsmasq = {
  #   enable = false;

  #   settings = {
  #     interface = "enp5s0";
  #     dhcp-range = ["192.168.1.50,192.168.1.250,24h"];
  #     dns-forward-max = 1000;

  #   };
  # };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable CUPS to print documents.

  hardware.sane.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  virtualisation = {
    vmware.host.enable = true;
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.package = pkgs.qemu_full;
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
    };
  };

  fonts.packages = with pkgs; [ nerdfonts ];
  system.stateVersion = "24.05"; # keep it!
}
