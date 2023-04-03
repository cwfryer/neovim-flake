{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.treesitter;
in
{
  options.vim.treesitter = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-treesitter";
    };
    textobjects = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-treesitter-objects with default config";
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
    [ nvim-treesitter ] ++
    (withPlugins cfg.textobjects [nvim-treesitter-objects]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- Treesitter config
    -- ---------------------------------------
      require'nvim-treesitter'.setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
          disable = {"python"},
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<nop>",
            node_decremental = "<bs>",
          }
        },
        ${writeIf cfg.textobjects ''
        textobjects = {
          enable = true,
          swap = { enable = true, },
          select = { enable = true, },
          move = { enable = true, },
          lsp_interop = { enable = true, },
        },
        ''}
      }
    '';
  };
}
