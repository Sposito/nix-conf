{inputs 
, pkgs
, nixpkgs-unstable
, ... }:
 

let
  unstable = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
  treesitterWithGrammars = (unstable.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.bash
    p.c
    p.comment
    p.dockerfile
    p.gitattributes
    p.gitignore
    p.json
    p.lua
    p.make
    p.markdown
    p.nix
    p.python
    p.toml
    p.yaml
    p.zig
  ]));


  treesitter-parsers = unstable.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };
in
{
    home.packages = with unstable; [
      lua5_1
      
      ripgrep
      fd
      lua-language-server
      tree-sitter
      ccls
    ];

  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    vimAlias = true;
    coc.enable = false;

    plugins = [
      treesitterWithGrammars
    ];
  };

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.file."./.config/nvim/init.lua".text = ''
    vim.opt.runtimepath:append("${treesitter-parsers}")
  '';

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };

}
