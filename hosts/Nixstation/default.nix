{
  pkgs,
  ...
}:
{

  imports = [
    ../common/default.nix
    ../common/keychron.nix
    ../common/network.nix
    ../common/nvidia/default.nix
    ../common/rclone.nix
    ../common/screen.nix
    ./hardware-configuration.nix
  ];

  systemd.services.custom-motd = {
    description = "Set custom Message of the Day";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "set-motd" ''
              cat << 'EOF' > /etc/motd
        ▗▖  ▗▖▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖▗▄▄▄▖▗▄▖▗▄▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖  ▗▖
        ▐▛▚▖▐▌  █   ▝▚▞▘ ▐▌     █ ▐▌ ▐▌ █    █  ▐▌ ▐▌▐▛▚▖▐▌
        ▐▌ ▝▜▌  █    ▐▌   ▝▀▚▖  █ ▐▛▀▜▌ █    █  ▐▌ ▐▌▐▌ ▝▜▌
        ▐▌  ▐▌▗▄█▄▖▗▞▘▝▚▖▗▄▄▞▘  █ ▐▌ ▐▌ █  ▗▄█▄▖▝▚▄▞▘▐▌  ▐▌

        [  Xeon E5-2650 v4 x48 ]-[   128 Gb ]-[  RTX 3090]

        ┏┳┓┓ •        ┏┓     •   
         ┃ ┣┓┓┏┓┏┓┏┓  ┗┓┏┓┏┓┏┓╋┏┓
         ┻ ┛┗┗┗┻┗┫┗┛  ┗┛┣┛┗┛┛┗┗┗┛
                 ┛      ┛        

        EOF
      '';
      RemainAfterExit = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=10de:2204,10de:1aef"
    ];
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-session
    gnomeExtensions.pop-shell
    cudatoolkit
    act
    # vmware-workstation
    xorg.xauth
    btrfs-progs
    #jetbrains.gateway
  ];

  environment.variables = {
    NIXOS_HOST = "nixstation";
    NIXOS_DE = "gnome";
  };
  fonts.packages = with pkgs; [ nerdfonts ];
  hardware.sane.enable = true;
  hardware.pulseaudio.enable = false;

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

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 11434 ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
    };
  };

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
  security.rtkit.enable = true;
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.wayland = false;
    };
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "thiago";
    flatpak.enable = true;
    xrdp = {
      enable = false;
      defaultWindowManager = "gnome-remote-desktop";
      openFirewall = true;
    };
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
  systemd = {
    services."getty@tty1".enable = false;
    services."autovt@tty1".enable = false;
  };

  systemd.timers.btrfs-scrub = {
    description = "Run Btrfs Scrub Daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.services = {
    btrfs-scrub = {
      description = "Daily Btrfs Scrub";
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        ExecStart = "${pkgs.btrfs-progs}/bin/btrfs scrub start -n 2 -B / && ${pkgs.btrfs-progs}/bin/btrfs scrub start -n 2 -B /mnt/hdd0";
      };
    };
  };
  system.stateVersion = "24.05"; # keep it!
  time.timeZone = "America/Sao_Paulo";
  virtualisation = {
    vmware.host.enable = false;
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.package = pkgs.qemu_full;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 30;
    algorithm = "zstd";
  };
}
