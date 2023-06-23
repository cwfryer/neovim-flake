{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
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
      vimscript = mkOption {
        type = types.bool;
        default = false;
        description = "Enable vimscript LSP Server";
      };
      html = mkOption {
        type = types.bool;
        default = false;
        description = "Enable html LSP Server";
      };
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
      [nvim-lspconfig null-ls inc-rename]
      ++ (withPlugins cfg.extras.neoconf [neoconf])
      ++ (withPlugins cfg.extras.neodev [neodev])
      ++ (withPlugins cfg.languages.rust [crates-nvim rust-tools]);

    vim.luaConfigRC = ''
      -- ---------------------------------------
      -- LSP Config
      -- ---------------------------------------

      -- Global LSP options
      require("inc_rename").setup()

      -- Utility function to goto by severity
      function diagnostic_goto(next, severity)
        local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
        severity = severity and vim.diagnostic.severity[severity] or nil
        return function()
          go({ severity = severity })
        end
      end

      -- Utility function to trigger formatting based on format engine
      function format()
        local buf = vim.api.nvim_get_current_buf()
        if vim.b.autoformat == false then
          return
        end
        local ft = vim.bo[buf].filetype
        local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

        vim.lsp.buf.format(vim.tbl_deep_extend("force", {
          bufnr = buf,
          filter = function(client)
            if have_nls then
              return client.name == "null-ls"
            end
            return client.name ~= "null-ls"
          end,
        },{}))
      end

      -- Utility function to set keymaps by LSP-active buffer
      local attach_keymaps = function(client, bufnr)
        map("n","<leader>cd",function() vim.diagnostic.open_float() end,{desc="Line Diagnostics",remap=false,silent=true,buffer=bufnr})
        map("n","<leader>cl","<cmd>LspInfo<cr>",{desc="Lsp Info",remap=false,silent=true,buffer=bufnr})
        map("n","gd","<cmd>Telescope lsp_definitions<cr>",{desc="Goto Definition",remap=false,silent=true,buffer=bufnr})
        map("n","gr","<cmd>Telescope lsp_references<cr>",{desc="References",remap=false,silent=true,buffer=bufnr})
        map("n","gD",function() vim.lsp.buf.declaration() end,{desc="Goto Declaration",remap=false,silent=true,buffer=bufnr})
        map("n","gI","<cmd>Telescope lsp_implementations<cr>",{desc="Goto Implementation",remap=false,silent=true,buffer=bufnr})
        map("n","gy","<cmd>Telescope lsp_type_definitions<cr>",{desc="Goto Type Definition",remap=false,silent=true,buffer=bufnr})
        map("n","K",function() vim.lsp.buf.hover() end,{desc="Hover",remap=false,silent=true,buffer=bufnr})
        map("n","gK",function() vim.lsp.buf.signature_help() end,{desc="Signature Help",remap=false,silent=true,buffer=bufnr})
        map("i","<c-k>",function() vim.lsp.buf.signature_help() end,{desc="Signature Help",remap=false,silent=true,buffer=bufnr})
        map("n","]d",function() diagnostic_goto(true) end,{desc="Next Diagnostic",remap=false,silent=true,buffer=bufnr})
        map("n","[d",function() diagnostic_goto(false) end,{desc="Prev Diagnostic",remap=false,silent=true,buffer=bufnr})
        map("n","]e",function() diagnostic_goto(true, "ERROR") end,{desc="Next Error",remap=false,silent=true,buffer=bufnr})
        map("n","[e",function() diagnostic_goto(false, "ERROR") end,{desc="Prev Error",remap=false,silent=true,buffer=bufnr})
        map("n","]w",function() diagnostic_goto(true, "WARN") end,{desc="Next Warning",remap=false,silent=true,buffer=bufnr})
        map("n","[w",function() diagnostic_goto(false, "WARN") end,{desc="Prev Warning",remap=false,silent=true,buffer=bufnr})
        map("n","<leader>cf",function() vim.lsp.buf.format() end,{desc="Format Document",remap=false,silent=true,buffer=bufnr})
        map("v","<leader>cf",function() vim.lsp.buf.format() end,{desc="Format Range",remap=false,silent=true,buffer=bufnr})
        map("n","<leader>ca",function() vim.lsp.buf.code_action() end,{desc="Code Action",remap=false,silent=true,buffer=bufnr})
        map(
          "n",
          "<leader>cA",
          function()
            vim.lsp.buf.code_action({
              context = {
                only = {
                  "source",
                },
                diagnostics = {},
              },
            })
          end,
          {desc="Source Action",remap=false,silent=true,buffer=bufnr}
        )
        map(
          "n",
          "<leader>cr",
          function()
            local inc_rename = require("inc_rename")
            return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
          end,
          {desc="Rename",expr = true}
        )
      end

      -- TODO is this even necessary?
      -- Auto set keys when Lsp server attaches
      -- vim.api.nvim_create_autocmd("LspAttach", {
      --   callback = function(args)
      --     local buffer = args.buf
      --     local client = vim.lsp.get_client_by_id(args.data.client_id)
      --     attach_keymaps(client, buffer)
      --   end,
      -- })

      -- Auto format autocommand to be used by null-ls
      local nls_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      format_callback = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = nls_augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = nls_augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                filter = function(client)
                  return client.name == "null-ls"
                end,
              })
            end,
          })
        end
      end

      default_on_attach = function(client, bufnr)
        attach_keymaps(client, bufnr)
        format_callback(client, bufnr)
      end

        ${writeIf cfg.extras.neodev ''
        require("neodev").setup()
      ''}

        ${writeIf cfg.extras.neoconf ''
        require("neoconf").setup()
      ''}

        ${writeIf cfg.autoFormatting ''
        -- Enable null-ls
        local null_ls = require("null-ls")
        require('null-ls').setup({
          root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
          sources = {
            null_ls.builtins.formatting.fish_indent.with({
              command = "${pkgs.fish}/bin/fish_indent";
            }),
            null_ls.builtins.diagnostics.fish.with({
              command = "${pkgs.fish}/bin/fish";
            }),
            null_ls.builtins.formatting.stylua.with({
              command = "${pkgs.stylua}/bin/stylua";
            }),
            null_ls.builtins.formatting.shfmt.with({
              command = "${pkgs.shfmt}/bin/shfmt";
            }),
            null_ls.builtins.formatting.black.with({
              command = "${pkgs.black}/bin/black";
            }),
            ${writeIf cfg.languages.rust ''
          null_ls.builtins.formatting.rustfmt,
        ''}
            ${writeIf cfg.languages.nix ''
          null_ls.builtins.formatting.alejandra.with({
            command = "${pkgs.alejandra}/bin/alejandra";
          }),
        ''}

          },
          on_attach = default_on_attach,
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
            on_attach = function(client,bufnr)
              default_on_attach(client, bufnr)
              vim.keymap.set("n", "<C-space>", require("rust-tools").hover_actions.hover_actions, { buffer = bufnr })
              vim.keymap.set("n", "<Leader>ch", require("rust-tools").hover_range.hover_range, { buffer = bufnr })
            end,
            cmd = {"${pkgs.rust-analyzer}/bin/rust-analyzer"},
            settings = {
              ["rust-analyzer"] = {
                experimental = {
                  procAttrMacros = true,
                },
                lru = {capacity = 32}, -- decrease memory usage
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

        ${writeIf cfg.languages.lua ''
        -- Lua config
        lspconfig.lua_ls.setup{
          settings = {
            runtime = { version = "LuaJIT" },
            diagnostics = {
                globals = {"vim"}
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("",true),
            },
            telemetry = { enable = false },
          };
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = {"${pkgs.sumneko-lua-language-server}/bin/lua-language-server"},
        }
      ''}

        ${writeIf cfg.languages.nix ''
        -- Nix config
        lspconfig.rnix.setup{
          capabilities = capabilities;
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
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

      ${writeIf cfg.languages.vimscript ''
        -- Vimscript config
        lspconfig.vimls.setup{
          capabilities = capabilities;
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
          end,
          cmd = { "${pkgs.nodePackages.vim-language-server}/bin/vim-language-server", "--stdio" }
        }
      ''}

      ${writeIf cfg.languages.html ''
        -- Vimscript config
        local html_caps = capabilities
        html_caps.textDocument.completion.completionItem.snippetSupport = true
        lspconfig.vimls.setup{
          capabilities = html_caps;
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr)
          end,
          cmd = { "${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-language-server-bin", "--stdio" }
        }
      ''}
    '';
  };
}
