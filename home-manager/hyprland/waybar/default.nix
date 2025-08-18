{
  ...
}:
{
  home.file.".config/waybar/config".text = builtins.readFile ./config.json;
  home.file.".config/waybar/style.css".text = builtins.readFile ./style.css;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
