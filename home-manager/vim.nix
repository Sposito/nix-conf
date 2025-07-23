{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  home.packages = with pkgs; [
    ripgrep
  ];
  programs.nixvim = {
    enable = true;
    colorschemes.nord.enable = true;
    opts = {
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
    };

    plugins = {
      lsp.enable = true;
      lsp.servers = {
        lua_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
        pyright.enable = true;
        clangd.enable = true;
        zls.enable = true;
        nixd.enable = true;
      };

      cmp.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;

      lspkind.enable = true;
      lsp-lines.enable = true;

      none-ls = {
        enable = true;
        sources = {
          formatting = {
            stylua.enable = true;
            shfmt.enable = true;
          };
          diagnostics = {
            luacheck.enable = true;
          };
          code_actions = {
            statix.enable = true;
          };
        };
      };
      conform-nvim.enable = true;

    };
  };
}

