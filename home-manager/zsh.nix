{ inputs
, lib
, config
, pkgs
, ...
}: {
    
 programs.zsh = {
    enable = true;
    enableAutosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
        enable = true;
        theme = "nord";
        plugins = [
            "git"
            "npm"
            "history"
            "node"
            "rust"
            "deno"
        ];
    };
};
    
}