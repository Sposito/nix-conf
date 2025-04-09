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
            size = "512M";
            start = "1M";
            type = "EF00";
            label = "EFI";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "16G";
            type = "8200";
            label = "Swap";
            content = {
              type = "swap";
              randomEncryption = false;
            };
          };

          root = {
            type = "8300";
            label = "NixOS";
            size = "870G";
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
