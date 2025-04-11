{ config, lib, ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            size = "128M";
            start = "1M";
            type = "EF00";
            label = "EFI";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          root = {
            type = "8300";
            label = "NixOS";
            size = "32G";
            content = {
              type = "btrfs";
              mountpoint = "/";
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                };
                "@nix" = {
                  mountpoint = "/nix";
                };
                "@home" = {
                  mountpoint = "/home";
                };
                "@log" = {
                  mountpoint = "/var/log";
                };
              };
              extraArgs = [ "-L" "nixos-root" ];
              mountOptions = [ "compress=zstd" "noatime" ];
            };
          };
        };
      };
    };
  };
}
