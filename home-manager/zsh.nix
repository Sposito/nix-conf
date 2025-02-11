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

    shellAliases ={
      ll = "ls -l";
      code = "nix-shell -p direnv vscode-fhs --run code .";

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

}
