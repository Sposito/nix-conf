{ config
, lib
, modulesPath
, ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "ahci"
    ];
    kernelParams = [ "amd_pstate=active" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/df74093a-637d-41a5-8c6a-2bf2dccc1506";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E9BA-D1A3";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/mnt/hdd0" = {
      device = "/dev/disk/by-uuid/940353dd-5774-4577-aba3-516d3f9c404d";
      fsType = "btrfs";
      options = [ "defaults" ];
    };
  };

  swapDevices = [ ];

  networking = {
    useDHCP = lib.mkDefault true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;  

}
