{ pkgs, config, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.thiago = {

    isNormalUser = true;
    extraGroups =
      [
        "networkmanager"
        "wheel"
      ]
      ++ ifTheyExist [
        "wireshark"
        "i2c"
        "docker"
        "git"
        "libvirtd"
        "libvirt"
        "video"
        "kvm"
        "scanner"
        "photos"
      ];
    openssh.authorizedKeys.keyFiles = [
      (builtins.fetchurl "https://github.com/sposito.keys")
    ];

    packages = [ pkgs.home-manager ];
  };

}
