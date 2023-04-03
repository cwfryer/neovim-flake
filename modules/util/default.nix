{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.util;
in
{
  options.vim.util = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enabe extra utilities";
    };
    sessions = mkOption {
      type = types.bool;
      default = false;
      description = "Enable persistence session management";
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
    (withPlugins cfg.sessions [ persistence ]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- Util Config
    -- ---------------------------------------
    ${writeIf cfg.sessions ''
      require('persistence').setup({
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" }
      })
    ''}
    '';
  };
}
