{ pkgs, ... }:
let
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.bash
    p.comment
    p.dockerfile
    p.gitattributes
    p.gitignore
    p.json
    p.lua
    p.make
    p.markdown
    p.nix
    p.rust
    p.toml
    p.yaml
    p.zig
  ]));

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };
in
{
  home.packages = with pkgs; [
    lua-language-server
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
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

  home.file."./.config/nvim/lua/thiago/init.lua".text = ''
    require("thiago.set")
    require("thiago.remap")
    vim.opt.runtimepath:append("${treesitter-parsers}")
  '';

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };

}