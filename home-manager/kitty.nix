{ inputs
, lib
, config
, pkgs
, ...
}: {
    
    programs.kitty = {
      enable = true;
      theme = "Nord";
      settings = {
        
        hide_window_decorations = "titlebar-only";
        font_size = 16;
        inactive_text_alpha = "0.6";
        macos_thicken_font = "0.75";
        background_blur = 1;
      };
    };
}

