{ pkgs, ... }: {

  imports = [
    ./disko.nix
  ];

  networking.hostName = "Nixtest";
  services = {
    xserver.enable = true;
    displayManager.sddm = {
      enable = true;
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    home-manager
  ];

  system.stateVersion = "23.11";
}
