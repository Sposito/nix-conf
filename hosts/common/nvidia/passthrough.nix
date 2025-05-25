{
  pkgs,
  ...
}:
let
  # Optional helper for manual (re)binding at runtime
  vfioBindScript = pkgs.writeShellScriptBin "vfio-bind" ''
    #!${pkgs.runtimeShell}
    DEV="$1"                    # e.g. 0000:81:00.0
    echo vfio-pci > /sys/bus/pci/devices/$DEV/driver_override
    ${pkgs.kmod}/bin/modprobe -i vfio-pci
    echo "$DEV" > /sys/bus/pci/drivers/vfio-pci/bind
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  boot = {
    # Load vfio early and bind the second GPU before NVIDIA can claim it
    initrd = {
      kernelModules = [ "vfio_pci" ];
      preDeviceCommands = ''
        DEVS="0000:81:00.0 0000:81:00.1"
        for DEV in $DEVS; do
          echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
        done
        modprobe -i vfio-pci
      '';
    };

    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];

    kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  environment.systemPackages = with pkgs; [
    vfioBindScript         # optional manual tool
  ];
}