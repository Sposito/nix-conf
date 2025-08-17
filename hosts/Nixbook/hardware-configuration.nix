{ config, lib, modulesPath, pkgs, ... }:

{
  imports =
    [
      (modulesPath + "/hardware/network/broadcom-43xx.nix")
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" "applesmc" "coretemp"];
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ ];
  };

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.wifi.powersave = true;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      USB_AUTOSUSPEND = 1;
      # Optional: quieter on battery
      CPU_BOOST_ON_BAT = 0;
    };
  };

  services.mbpfan = {
    enable = true;
    lowTemp = 55;
    highTemp = 70;
    maxTemp = 88;       # below TJmax, avoids thermal panic
    minFanSpeed = 2000; # typical Apple idle
    maxFanSpeed = 6200; # Apple ceiling
    verbose = false;
  };
  environment.systemPackages = with pkgs; [ lm_sensors powertop ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
