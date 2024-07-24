{ config, lib, pkgs, ... }:
{
    networking.hostName = "Nixstation";
    networking.networkmanager.enable = true;
    services.tailscale.enable = true;
    services.samba.enable = true;
    services.openssh.enable = true;
}