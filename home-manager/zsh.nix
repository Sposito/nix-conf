{ inputs
, lib
, config

, ...
}: {

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
    eval "$(direnv hook zsh)"
    '';
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "history"
        "deno"
      ];
    };
  };

}
