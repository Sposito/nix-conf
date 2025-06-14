{
  config,
  pkgs,
  ...
}:
{
  imports = [
    #  ./passthrough.nix
  ];

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
    sunshine = {
      enable = false;
      # autoStart = true;
      # openFirewall = true;
      package = pkgs.sunshine.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
          "-DSUNSHINE_ENABLE_CUDA=OFF"
          "-DCUDA_FAIL_ON_MISSING=OFF"
        ];
      });
    };
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
    #looking-glass-client
    nvidia-container-toolkit
    cudaPackages.cudatoolkit
    cudaPackages.cuda_nvcc
  ];

}
