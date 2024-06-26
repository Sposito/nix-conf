{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.thiago = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" ]
    ++ ifTheyExist [
      "minecraft"
      "network"
      "wireshark"
      "i2c"
      "mysql"
      "docker"
      "podman"
      "git"
      "libvirtd"
      "deluge"
    ];

    # openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/misterio/ssh.pub) ];
    # hashedPasswordFile = config.sops.secrets.misterio-password.path;
    packages = [ pkgs.home-manager ];
  };

  # sops.secrets.misterio-password = {
  #   sopsFile = ../../secrets.yaml;
  #   neededForUsers = true;
  # };

  # home-manager.users.misterio = import ../../../../home/misterio/${config.networking.hostName}.nix;

  # security.pam.services = { swaylock = { }; };
}
