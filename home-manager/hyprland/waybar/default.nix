{
  ...
}:
{

  home.file.".config/waybar/config".text = ''
{
  "layer": "top",
  "position": "top",
  "exclusive": true,
  "modules-left": [
    "hyprland/workspaces",
    "hyprland/window"
  ],
  "modules-center": [
    "clock",
    "temperature#cpu"
  ],
  "modules-right": [
    "pulseaudio",
    "battery",
    "network",
    "tray"
  ],
  "clock": {
    "format": "{:%d/%m %H:%M}",
    "interval": 1
  },
  "temperature#cpu": {
    "hwmon-path": "/sys/class/hwmon/hwmon1/temp1_input",
    "format": " {temperatureC}°C",
    "critical-threshold": 90,
    "format-icons": [
      "",
      "",
      ""
    ]
  },
  "battery": {
    "format": "{capacity}% {icon}",
    "format-charging": "{capacity}% ⚡",
    "format-icons": [
      "",
      "",
      "",
      "",
      ""
    ]
  },
  "network": {
    "format-wifi": " {essid}",
    "format-ethernet": " {ipaddr}",
    "format-disconnected": "  "
  },
  "pulseaudio": {
    "format": "{volume}% {icon}",
    "format-muted": "",
    "format-icons": [
      "",
      "",
      ""
    ]
  }
}
  '';
  home.file.".config/waybar/style.css".text = builtins.readFile ./style.css;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
}
