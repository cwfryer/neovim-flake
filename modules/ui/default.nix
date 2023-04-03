{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.ui;
in
{
  options.vim.ui = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable UI plugins";
    };
    uiTweaks = {
      system = mkOption {
        type = types.enum [ "nvim-notify" "noice.nvim" ];
        default = "noice.nvim";
        description = "Which UI system to use: nvim-notify or noice.nvim";
			};
      interfaces = mkOption {
        type = types.bool;
        default = false;
        description = "Enable dressing.nvim better UI elements";
			};
      icons = mkOption {
        type = types.bool;
        default = false;
        description = "Enable nvim-web-devicons fancy icon support";
			};
      components = mkOption {
        type = types.bool;
        default = false;
        description = "Enable nui.nvim UI components";
			};
      indents = mkOption {
        type = types.bool;
        default = false;
        description = "Enable visible indent guides via indent-blankline.nvim";
			};
    };
    uiAdditions = {
      bufferline = mkOption {
        type = types.bool;
        default = false;
        description = "Enable bufferline.nvim buffer bar at top";
			};
      lualine = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable lualine statusline at bottom";
        };
        improveContext = mkOption {
          type = types.bool;
          default = false;
          description = "Add enhanced code context to lualine with nvim-navic";
        };
			};
      indents = mkOption {
        type = types.bool;
        default = false;
        description = "Enable animated indent guide via mini.indentscope";
			};
      dashboard = mkOption {
        type = types.enum [ "alpha" "mini.starter" ];
        default = "alpha";
        description = "Enable startup dashboard via alpha or mini.starter";
			};
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
    [] ++
    (if cfg.uiTweaks.system == "noice.nvim" then [noice] else [nvim-notify]) ++
    (withPlugins cfg.uiTweaks.interfaces [dressing]) ++
    (withPlugins cfg.uiTweaks.icons [nvim-web-devicons]) ++
    (withPlugins cfg.uiTweaks.components [nui]) ++
    (withPlugins cfg.uiTweaks.indents [indent-blankline]) ++
    (withPlugins cfg.uiAdditions.bufferline [bufferline]) ++
    (withPlugins cfg.uiAdditions.lualine.enable [lualine]) ++
    (withPlugins cfg.uiAdditions.lualine.improveContext [nvim-navic]) ++
    (withPlugins cfg.uiAdditions.indents [mini-indentscope]) ++
    (withPlugins (cfg.uiAdditions.dashboard) == "alpha" [alpha]) ++
    (withPlugins (cfg.uiAdditions.dashboard) == "mini.starter" [mini-starter]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- UI Config
    -- ---------------------------------------

    ${writeIf (cfg.uiTweaks.system == "noice.nvim") ''
      require('noice').setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
      })
    ''}
    ${writeIf (cfg.uiTweaks.system == "nvim-notify") ''
      vim.notify = require("notify").setup({
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
    ''}
    ${writeIf cfg.uiTweaks.interfaces ''
      require('dressing').setup({})
    ''}
    ${writeIf cfg.uiTweaks.icons ''
      require('nvim-web-devicons').setup({})
    ''}
    ${writeIf cfg.uiTweaks.components ''
      require('nui').setup({})
    ''}
    ${writeIf cfg.uiTweaks.indents ''
      require("indent_blankline").setup({
        char = "|",
        filetype_exclude = {"help", "alpha", "dashboard", "neo-tree", "trouble"},
        show_trailing_blankline_indent = false,
        show_current_context = false,
      })
    ''}
    ${writeIf cfg.uiAdditions.bufferline ''
      vim.opt.termguicolors = true
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          diagnostics_indicator = function(_,_,diag)
            local icons = require("icon_file").icons.diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
    ''}
    ${writeIf cfg.uiAdditions.lualina.enable ''
      require('lualine').setup({
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" }},
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons...,
                warn = icons...,
                info = icons...,
                hint = icons...,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "xxx", readonly = "", unnamed = "" } },
            ${writeIf cfg.uiAdditions.lualine.improveContext ''
            {
              function() return require('nvim-navic').get_location() end,
              cond = require('nvim-navic').is_available() end,
            },
            ''}
          },
          lualine_x = {
            ${writeIf (cfg.uiTweaks.system == "noice.nvim") ''
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return require("noice").api.status.command.has() end,
            },
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return require("noice").api.status.mode.has(), end,
            },
            ''}
            {
              "diff",
              symbols = {
                added = icons...,
                modified = icons...,
                removed = icons...,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return "xxx" .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree" },
      })
    ''}
    ${writeIf cfg.uiAdditions.indents ''
    require("mini.indentscope").setup({
      symbol = "|",
      options = { try_as_border = true },
    })
    ''}
    ${writeIf (cfg.uiAdditions.dashboard == "mini.starter") ''
    require("mini.starter").setup()
    ''}
    ${writeIf (cfg.uiAdditions.dashboard == "alpha") ''
     -- TODO
    ''}
    '';
  };
}
