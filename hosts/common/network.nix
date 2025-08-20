{ pkgs, ... }:
{
  networking = {
    hostName = "Nixstation";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        2375
        4780
        11470
        25565
      ];
      allowedUDPPorts = [
        8888
        8899
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
      hosts = [ "unix:///var/run/docker.sock" ];
      features.cdi = true;
      userland-proxy = false;
      experimental = true;
      metrics-addr = "0.0.0.0:9323";
  };

    # daemon.settings = {

    #   hosts = [
    #     "unix:///var/run/docker.sock"
    #   ];

    #   features = {
    #     cdi = true;
    #   };

    #   userland-proxy = false;
    #   experimental = true;
    #   metrics-addr = "0.0.0.0:9323";

    #   default-runtime = "nvidia";
    #   runtimes = {
    #     nvidia = {
    #       path = "nvidia-container-runtime";
    #     };
    #     nvidia-cdi = {
    #       path = "nvidia-container-runtime.cdi";
    #     };
    #     nvidia-legacy = {
    #       path = "nvidia-container-runtime.legacy";
    #     };
    #   };
    # };
  };

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
        # shared = {
        #  path = "/home/thiago/Downloads/oblivion";
        #  browseable = true;
        #  writable = false;
        #  guestOk = true;
        #  "force user" = "thiago";
        # };
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
