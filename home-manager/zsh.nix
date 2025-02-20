{ inputs
, lib
, config
, pkgs
, ...
}:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';

    shellAliases = {
      "ll" = "ls -l";
      "code" = "code-insiders";
      "pbcopy" = "xclip -selection clipboard";
      "pbpaste" = "xclip -selection clipboard -o";
    };

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "history"
      ];
    };
  };

  home.packages = with pkgs; [ xclip ];
}
