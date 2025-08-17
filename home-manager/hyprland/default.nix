{
  ...
}:

{
  imports = [
    ./waybar
  ];
  
  home.sessionVariables = {
    fileManager = "thunar";
    menu = "fuzzel --show drun";
    run = "fuzzel --show run";
    file = "fuzzel --show file";
  };

  home.file.".config/fuzzel/fuzzel.ini".text = ''
[main]
font=JetBrainsMono Nerd Font:size=12
icon-theme=Papirus
icon-size=16
layer=overlay
anchor=top
margin-top=10
margin-left=10
margin-right=10
width=40
height=30
background-color=#2e3440
text-color=#eceff4
selection-color=#5e81ac
selection-text-color=#eceff4
border-width=1
border-color=#4c566a
corner-radius=8
padding-left=12
padding-right=12
padding-top=8
padding-bottom=8
horizontal-pad=8
vertical-pad=4
dpi-aware=yes
prompt-text=>
log-level=warning
log-no-syslog=yes
log-file=

[keybindings]
scroll-up=ctrl+k,Up,scroll-0
scroll-down=ctrl+j,Down,scroll-1
page-up=Page_Up,scroll-page-0
page-down=Page_Down,scroll-page-1
beginning-of-list=Home
end-of-list=End
cancel=ctrl+g,Escape
select=Return,KP_Enter
select-1=1
select-2=2
select-3=3
select-4=4
select-5=5
select-6=6
select-7=7
select-8=8
select-9=9
  '';

  home.file.".config/kanshi/config".source = ./kanshi.config;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      layerrule = "ignorezero, waybar";
      bind = [
        "$mod, q, exec, kitty"
        "$mod, c, killactive,"
        "$mod, m, exit,"
        "$mod, e, exec, $fileManager"
        "$mod, v, togglefloating"
        "$mod, r, exec, $menu"
        "$mod, p, pseudo,"
        "$mod, j, togglesplit,"
        
        "$mod, d, exec, $run"
        "$mod, f, exec, $file"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];
      monitor = [ 
        ",preferred,auto,auto"
        "HDMI-A-2,1920x1080@50,0x0,1"
        "eDP-1,2560x1600@60,1920x0,2"
      ];

      general = {
        gaps_in = 2;
        gaps_out = 3;
        border_size = 1;

        #  col = {
        #   active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        #   inactive_border = "rgba(595959aa)";
        # };
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 2;
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 17;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes, please :)";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
        vfr = true;
        vrr = 0;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = -0.1;
        touchpad = {
          "tap-to-click" = true;
          "tap-and-drag" = true;
          "natural_scroll" = true;
          "middle_button_emulation" = true;
          "clickfinger_behavior" = true;
          "tap_button_map" = "lmr";
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };
    };
  };
}
