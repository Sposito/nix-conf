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
      (builtins.fetchurl {
        url = "https://github.com/sposito.keys";
        sha256 = "0bwqj8si0q6kp9cdjgkp9kfz17f24wf476zqzvxbygn6f4av0wh2";
      })
    ];

    packages = [ pkgs.home-manager ];
  };

}
