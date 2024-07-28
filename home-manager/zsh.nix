{ inputs
, lib
, config
, pkgs
, ...
}: {
    
 programs.zsh = {
    enable = true;
    programs.zsh.autosuggestion.enable = true;
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