{ config, lib, pkgs, ... }:
{
  networking.hostName = "Nixstation";
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  virtualisation.docker =
    {
      enable = true;
      storageDriver = "btrfs";
#      rootless = {
 #       enable = true;
  #      setSocketVariable = true;
   #   };
      daemon.settings = {
        userland-proxy = false;
        experimental = true;
        metrics-addr = "0.0.0.0:9323";
        ipv6 = true;
        fixed-cidr-v6 = "fd00::/80";
      };
    };

  environment.systemPackages = with pkgs; [
    docker
  ];
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

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
