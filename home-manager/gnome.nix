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
        ""
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
        "Forge@forge-ext"
        "blur-my-shell@aunetx"
      ];
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      pipelines = ''
        {
          'pipeline_default': {
            'name': <'Default'>,
            'effects': <[
              <{
                'type': <'native_static_gaussian_blur'>,
                'id': <'effect_99075046663473'>,
                'params': <{
                  'unscaled_radius': <64>,
                  'brightness': <0.93>
                  }>
                }>
              ]>
            }
        }
      '';
      "settings-version" = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      blur-on-overview = false;
      brightness = 1.0;
      dynamic-opacity = false;
      opacity = 255;
      sigma = 34;
      whitelist = [ "kitty" ];
    };

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      pipeline = "pipeline_default";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
      unblur-in-overview = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/hidetopbar" = {
      compatibility = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
      style-components = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = 0.6;
      force-light-text = false;
      pipeline = "pipeline_default";
      sigma = 30;
      static-blur = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.6;
      sigma = 30;
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnomeExtensions.pop-shell
    gnomeExtensions.forge
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar

    nordzy-icon-theme

  ];
}
