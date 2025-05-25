{ pkgs, ... }:
{
  networking = {
    hostName = "Nixstation";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        11470
        25565
        2375
      ];
    };
  };

  services = {
    tailscale.enable = true;
    openssh.enable = true;
    openssh.settings.X11Forwarding = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_25;
    storageDriver = "btrfs";

    daemon.settings = {

      hosts = [
        "unix:///var/run/docker.sock"
        "tcp://100.99.44.69:2375"
      ];

      features = {
        cdi = true;
      };

      userland-proxy = false;
      experimental = true;
      metrics-addr = "0.0.0.0:9323";
    };
  };

  environment.systemPackages = with pkgs; [
    nvidia-docker
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";

        # "use sendfile" = "yes";
        # "max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.0. 192.168. 192.168.122.55 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        security = "user";
      };

      # shares = {
      #   OneDrive = ''
      #     path = "/run/media/thiago/hdd0/OneDrive/"
      #     browseable = "yes"
      #     "read only" = "no"
      #     "guest ok" = "no"
      #     "create mask" = "0644"
      #     "directory mask" = "0755"
      #     "force user" = "thiago"
      #     "force group" = "users"
      #   '';
      # };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
