{ config
, lib
, pkgs
, modulesPath
, inputs
, ...
}:

let
  machineKey = inputs.machine-key.packages.${pkgs.system}.default;
in
{
  imports = [
    (modulesPath + "/hardware/network/broadcom-43xx.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment.systemPackages = [
    machineKey
  ];

  # Ensure secure permissions on output file
  systemd.tmpfiles.rules = [
    "f /etc/machine_key.bin 0400 root root - -"
  ];

  # Run the script once at boot
  systemd.services.generate-machine-key = {
    description = "Generate machine-specific private key";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${machineKey}/bin/generate-key.sh /etc/machine_key.bin";
      RemainAfterExit = true;
    };
  };
}
