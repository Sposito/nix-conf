{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false; # keep it like that for now, unstable!!
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services = {
    sunshine.enable = true;
    sunshine.autoStart = true;
    sunshine.openFirewall = true;
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
  };
  nixpkgs.config.cudaSupport = true;
  environment.systemPackages = with pkgs; [
    mesa
    glxinfo
    libepoxy
    libglvnd
    nvidia-container-toolkit
  ];

}
