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
<<<<<<< HEAD
        sha256 = "0bwqj8si0q6kp9cdjgkp9kfz17f24wf476zqzvxbygn6f4av0wh2";
=======
        sha256 = "0pap85cnr10c6wwwkp5hl7q4w0fgh8bvn0cmr0vwvhwz6r89jpra";
>>>>>>> d0de9f26861fb72aa9e5692e594f85ada363ccb0
      })
    ];

    packages = [ pkgs.home-manager ];
  };

}
