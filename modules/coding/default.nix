{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.coding;
in
{
  options.vim.coding = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable coding plugins";
    };
    snippets = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable LuaSnip snippets engine";
      };
      useFriendlySnippets = {
        type = types.bool;
        default = false;
        description = "Use friendly-snippets collection";
      };
    };
    completion = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auto-completion";
      };
      useSuperTab = mkOption {
        type = types.bool;
        default = false;
        description = "Use SuperTab for completion";
      };
      completeFromLSP = mkOption {
        type = types.bool;
        default = false;
        description = "Include LSP auto-complete suggestions";
      };
      completeFromBuffer = mkOption {
        type = types.bool;
        default = false;
        description = "Include current buffer auto-complete suggestions";
      };
      completeFromPath = mkOption {
        type = types.bool;
        default = false;
        description = "Include path auto-complete suggestions";
      };
      completeFromLuaSnip = mkOption {
        type = types.bool;
        default = false;
        description = "Include LuaSnip auto-complete suggestions";
      };
    };
    helpers = {
      autoPair = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auto-paired characters";
      };
      surround = mkOption {
        type = types.bool;
        default = false;
        description = "Enable surround functionality";
      };
      comment = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable line/block comment commands";
        };
        useTreeSitterContext = {
          type = types.bool;
          default = false;
          description = "Use Treesitter to improve comment string recognition";
        };
      };
      betterAISelection = mkOption {
        type = types.bool;
        default = false;
        description = "Enable improved A and I text selection";
      };
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; 
    [] ++
    (withPlugins cfg.snippets.enable [lua-snip]) ++
    (withPlugins cfg.snippets.useFriendlySnippets [friendly-snippets]) ++
    (withPlugins cfg.completion.enable [nvim-cmp]) ++
    (withPlugins cfg.completion.completeFromLSP [cmp-nvim-lsp]) ++
    (withPlugins cfg.completion.completeFromBuffer [cmp-buffer]) ++
    (withPlugins cfg.completion.completeFromPath [cmp-path]) ++
    (withPlugins cfg.completion.completeFromLuaSnip [cmp-luasnip]) ++
    (withPlugins cfg.helpers.autoPair.enable [mini-pairs]) ++
    (withPlugins cfg.helpers.surround.enable [mini-surround]) ++
    (withPlugins cfg.helpers.comment.useTreeSitterContext [nvim-ts-commentstring]) ++
    (withPlugins cfg.helpers.comment.enable [mini-comment]) ++
    (withPlugins cfg.helpers.betterAISelection.enable [mini-ai]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- Coding Config
    -- ---------------------------------------
      ${writeIf cfg.snippets.enable ''
        require'luasnip'.setup({
          opts = {
            history = true,
            delete_check_events = "TextChanged",
          },
          keys = {
            {
              "<tab>",
              function()
                return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
              end,
              expr = true, silent = true, mode = i,
            },
            { "<tab>" function() require("luasnip").jump(1) end, mode = "s"},
            { "<s-tab>" function() require("luasnip").jump(-1) end, mode = {"i",s"}},
          },
        })
        ${writeIf cfg.snippets.useFriendlySnippets ''
          require("luasnip.loaders.from_vscode").lazy_load()
        ''}
      ''}
      ${writeIf cfg.completion.enable ''
        local cmp = require'cmp'
        cmp.setup({
          completion = {
            completeopt = "menu,menuone,noinsert",
          },
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          ${if cfg.completion.useSuperTab then ''
            mapping = {
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require("luasnip").expand_or_jumpable() then
                  require("luasnip").expand_or_jump()
                elseif has_words_before() then
                  cmp.complete()
                else
                  fallback()
                end
              end, { "i", "s" }),

              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require("luasnip").jumpable(-1) then
                  require("luasnip").jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" }),
            },
          '' else ''
            mapping = cmp.mapping.preset.insert({
              ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
              ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
              ["<C-b>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.abort(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<S-CR"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              }),
            }),
          ''};
          sources = cmp.config.sources({
            ${writeIf cfg.completion.completeFromLSP ''{ name = "nvim_lsp" },''}
            ${writeIf cfg.completion.completeFromBuffer ''{ name = "luasnip" },''}
            ${writeIf cfg.completion.completeFromPath ''{ name = "buffer" },''}
            ${writeIf cfg.completion.completeFromLuaSnip ''{ name = "path" },''}
          }),
          formatting = {
            format = function(_, item)
              local icons = require("").icons.kinds
              if icons[item.kind] then
                item.kind = icons[item.kind] .. item.kind
              end
              return item
            end,
          },
          experimental = {
            ghost_text = { hl_group = "LspCodeLens" },
          },
        })
      ''}
      ${writeIf cfg.helpers.autoPair ''
        require("mini.pairs").setup()
      ''}
      ${writeIf cfg.helpers.surround ''
        require("mini.surround").setup({
          mappings = {
            add = "gza",
            delete = "gzd",
            find = "gzf",
            find_left = "gzF",
            highlight = "gzh",
            replace = "gzr",
            update_n_lines = "gzn",
          };
        })
      ''}
      ${writeIf cfg.helpers.comment.enable ''
        require("mini.comment").setup({
          ${writeIf cfg.helpers.comment.useTreeSitterContext ''
            hooks = {
              pre = function()
                require("ts_context_commentstring.internal").update_commentstring({})
              end,
            },
          ''}
        })
      ''}
      ${writeIf cfg.helpers.betterAISelection ''
      ''}
    '';
  };
}
