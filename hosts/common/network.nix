{ config, lib, pkgs, ... }:
{
  networking.hostName = "Nixstation";
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 192.168. 192.168.122.55 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      OneDrive = {
        path = "/run/media/thiago/hdd0/OneDrive/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "thiago";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
