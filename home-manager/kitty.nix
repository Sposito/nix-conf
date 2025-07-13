{ ... }:
{
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+alt+left" = "resize_window narrower";
      "ctrl+alt+right" = "resize_window wider";
      "ctrl+alt+up" = "resize_window taller";
      "ctrl+alt+down" = "resize_window shorter";
    };
    settings = {
      hide_window_decorations = "titlebar-only";
      font_size = 16;
      font = "ComicShannsMono Nerd Font Mono";
      inactive_text_alpha = "0.6";
      macos_thicken_font = "0.75";
      background_blur = 1;
    };
    themeFile = "Nord";
  };
}
