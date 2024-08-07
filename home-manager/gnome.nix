{ pkgs, ... }:

{

  dconf.settings = {

    "org/gnome/shell" = {
      disable-user-extensions = false;
      favorite-apps = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "org.gnome.Calendar.desktop"
        "code.desktop"
        "kitty.desktop"
      ];
      
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
        "Forge@forge-ext"
      ];
    };
  };


  home.packages = with pkgs; [
    gnomeExtensions.user-themes
    gnomeExtensions.forge
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
    nordzy-icon-theme
    
  ];
}
