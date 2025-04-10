{ pkgs, config, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.thiago = {

    isNormalUser = true;
    initialPassword = "changeme";
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
      (builtins.fetchurl{ 
        url = "https://github.com/sposito.keys";
        sha256 = "0pap85cnr10c6wwwkp5hl7q4w0fgh8bvn0cmr0vwvhwz6r89jpra";
        })
    ];

    packages = [ pkgs.home-manager ];
  };

}
