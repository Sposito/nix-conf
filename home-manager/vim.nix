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
            #  luacheck.enable = true;
          };
          code_actions = {
            statix.enable = true;
          };
        };
      };
      conform-nvim.enable = true;

    };
    extraConfigLua = ''
      local cmp = require'cmp'

      cmp.setup({
        mapping = {
          ['<C-Space>'] = cmp.mapping.complete(),        -- trigger manually
          ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- confirm with Enter
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        },
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local buf = args.buf
            local opts = { buffer = buf }

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

            vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
            vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
          end
        })
      })
    '';
  };
}

