{ config, lib, pkgs, ... }:
{
    boot.initrd.availableKernelModules = [ i2c-dev ];

    environment.systemPackages = with pkgs; [
        ddcutil
        ddcui
    ];
}