{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.thiago = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" ]
    ++ ifTheyExist [
      "wireshark"
      "i2c"
      "docker"
      "podman"
      "git"
      "libvirtd"
    ];

    packages = [ pkgs.home-manager ];
  };




}
