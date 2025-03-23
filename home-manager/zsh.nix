{ pkgs
, ...
}:

{
  home.file."scripts/lsgpu.sh" = {
    source = ./scripts/lsgpu.sh;
    executable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      eval "$(direnv hook zsh)"
    '';

    shellAliases = {
      "vi" = "nvim";
      "vim" = "nvim";
      "ll" = "ls -l";
      "code" = "code-insiders";
      "pbcopy" = "xclip -selection clipboard";
      "pbpaste" = "xclip -selection clipboard -o";
      "lsgpu" = "$HOME/scripts/lsgpu.sh";
    };

    oh-my-zsh = {
      enable = true;
      theme = "bureau";
      plugins = [
        "git"
        "history"
      ];
    };
  };

  home.packages = with pkgs; [ xclip ];
}
