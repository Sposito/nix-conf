{ inputs
# , lib
# , config
# , pkgs
, ...
}: {
users.defaultUserShell = pkgs.zsh;
environment.shells = with pkgs; [ zsh ];
 programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
        enable = true;
        plugins = [
            "git"
            "history"
            "deno"
        ];
    };
};
    
}