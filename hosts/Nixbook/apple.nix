{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    "hid_apple.iso_layout=0"
  ];
  powerManagement = {
    cpuFreqGovernor = "schedutil";
    powerUpCommands = lib.mkBefore "${pkgs.kmod}/bin/modprobe brcmfmac";
    powerDownCommands = lib.mkBefore "${pkgs.kmod}/bin/rmmod brcmfmac";
  };
  hardware.facetimehd.enable = lib.mkDefault
    (config.nixpkgs.config.allowUnfree or false);

  services.mbpfan.enable = lib.mkDefault true;
}
