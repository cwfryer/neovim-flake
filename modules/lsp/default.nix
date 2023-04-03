{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.lsp;
in
{
  options.vim.lsp = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable LSP plugins";
    };
    extras = {
      neoconf = mkOption {
        type = types.bool;
        default = false;
        description = "Enable neoconf settings manager";
      };
      neodev = mkOption {
        type = types.bool;
        default = false;
        description = "Enable neodev help for neovim apis & init.lua";
      };
    };
    autoFormatting = mkOption {
      type = types.bool;
      default = false;
      description = "Enable auto-formatting via null-ls linters";
    };

    languages = {
      lua = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Lua LSP Server";
      };
      nix = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nix LSP Server";
      };
      rust = mkOption {
        type = types.bool;
        default = false;
        description = "Enable rust LSP Server";
      };
      go = mkOption {
        type = types.bool;
        default = false;
        description = "Enable go LSP Server";
      };
      python = mkOption {
        type = types.bool;
        default = false;
        description = "Enable python LSP Server";
      };
      typescript = mkOption {
        type = types.bool;
        default = false;
        description = "Enable typescript LSP Server";
      };
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; 
      [ nvim-lspconfig null-ls ] ++
      (withPlugins cfg.languages.rust [ crates-nvim rust-tools ]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- LSP Config
    -- ---------------------------------------

    -- Global LSP options

    function diagnostic_goto(next, severity)
      local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
      severity = severity and vim.diagnostic.severity[severity] or nil
      return function()
        go({ severity = severity })
      end
    end

    local attach_keymaps = function(client, bufnr)
      local opts = { noremap=true, silent=true }

      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cd', vim.diagnostic.open_float, {desc="Line Diagnostics",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cl', '<cmd>LspInfo<CR>', {desc="LSP Info",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>Telescope lsp_definitions<CR>', {desc="Goto Definition",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>Telescope lsp_references<CR>', {desc="References",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', vim.lsp.buf.declaration, {desc="Goto Declaration",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gI', '<cmd>Telescope lsp_implementations<CR>', {desc="Goto Implementation",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', {desc="Goto Type Definition",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', vim.lsp.buf.hover, {desc="Hover",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gK', vim.lsp.buf.signature_help, {desc="Signature Help",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'i', '<c-k>', vim.lsp.buf.signature_help, {desc="Signature Help",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', diagnostic_goto(true), {desc="Next Diagnostic",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', diagnostic_goto(false), {desc="Prev Diagnostic",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', ']e', diagnostic_goto(true, "ERROR"), {desc="Next Error",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '[e', diagnostic_goto(false, "ERROR"), {desc="Prev Error",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', ']w', diagnostic_goto(true, "WARN"), {desc="Next Warning",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '[w', diagnostic_goto(false, "WARN"), {desc="Prev Warning",table.unpack(opts)})
      -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', format, {desc="Format Document",table.unpack(opts)})
      -- vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>cf', format, {desc="Format Range",table.unpack(opts)})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', vim.lsp.buf.code_action, {desc="",table.unpack(opts)})
      -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cA', 'action<CR>', {desc="Code Action",table.unpack(opts)})
    end

    format_callback = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          local params = require'vim.lsp.util'.make_formatting_params({})
          client.request('textDocument/formatting', params, nil, bufnr)
        end
      })
    end

    default_on_attach = function(client, bufnr)
      attach_keymaps(client, bufnr)
      format_callback(client, bufnr)
    end

      ${writeIf cfg.extras.neodev ''
        require("neodev").setup({})
      ''}

      ${writeIf cfg.extras.neoconf ''
        require("neoconf").setup({})
      ''}

      ${writeIf cfg.autoFormatting ''
      -- Enable null-ls
      require('null-ls').setup({
        root_dir = require("null-ls.utlls").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          null-ls.builtins.formatting.fish_indent.with({
            command = "${pkgs.fish}/bin/fish_indent";
          }),
          null-ls.builtins.diagnostics.fish.with({
            command = "${pkgs.fish}/bin/fish";
          }),
          null-ls.builtins.formatting.stylua.with({
            command = "${pkgs.stylua}/bin/stylua";
          }),
          null-ls.builtins.formatting.shfmt.with({
            command = "${pkgs.shfmt}/bin/shfmt";
          }),
          null-ls.builtins.formatting.flake8.with({
            command = "${pkgs.python311Packages.flake8}/bin/flake8";
          }),
          ${writeIf cfg.languages.nix ''
            null-ls.builtins.formatting.alejandra.with({
              command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
            })
          ''}
        },
        on_attach = default_on_attach
      })
      ''}

    -- Enable lspconfig
    local lspconfig = require('lspconfig')

    local capabilities = vim.lsp.protocol.make_client_capabilities()

      ${writeIf cfg.languages.rust ''
        -- Rust config
        local rustopts = {
          tools = {
            autoSetHints = true,
            hover_with_actions = false,
            inlay_hints = {
              only_current_line = false,
            }
          },
          server = {
            capabilities = capabilities,
            on_attach = default_on_attach,
            cmd = ${"${pkgs.rust-analyzer}/bin/rust-analyzer"}
            settings = {
              ["rust-analyzer"] = {
                experimental = {
                  procAttrMacros = true,
                },
              },
            }
          }
        }

        require('crates').setup {
          null_ls = {
            enabled = true,
            name = "crates.nvim"
          }
        }
        require('rust-tools').setup(rustopts)
      ''}

      ${writeIf cfg.languages.python ''
        -- Python config
        lspconfig.pyright.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${pkgs.nodePackages.pyright}/bin/pyright-langserver", "--stdio"},
        }
      ''}

      ${writeIf cfg.languages.nix ''
        -- Nix config
        lspconfig.rnix.setup{
          capabilities = capabilities;
          on_attach = function(client, bufnr)
            attach_keymaps()
          end,
          cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"},
        }
      ''}

      ${writeIf cfg.languages.go ''
        -- Go config
        lspconfig.gopls.setup{
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${pkgs.gopls}/bin/gopls", "serve"},
        }
      ''}

      ${writeIf cfg.languages.typescript ''
        -- Typescript config
        lspconfig.tsserver.setup{
          capabilities = capabilities;
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
          end,
          cmd = { "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server", "--stdio" }
        }
      ''}
    '';
  };
}
