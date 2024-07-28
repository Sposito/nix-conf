{ inputs
# , lib
# , config
# , pkgs
, ...
}: {
    
 programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
        enable = true;
        theme = "nord";
        plugins = [
            "git"
            "history"
            "deno"
        ];
    };
};
    
}