{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rclone
    fuse3  # Required for mounting
  ];

  users.users.thiago = {
    extraGroups = [ "fuse" ];
  };
}
