{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.colorscheme;
in
{
  options.vim.colorscheme = {
    set = mkOption {
      type = types.enum [ "catppuccin" "tokyonight" "oceanicnext" ];
      default = "oceanicnext";
      description = "Choose colorscheme (catppuccin, tokyonight, oceanicnext)";
    };
    transparent = mkOption {
      type = types.bool;
      default = false;
      description = "Toggle transparent background";
    };
  };
  config = {
    vim.startPlugins = with pkgs.neovimPlugins;
      (withPlugins (cfg.set == "catppuccin") [ catppuccin ]) ++
      (withPlugins (cfg.set == "tokyonight") [ tokyonight ]) ++
      (withPlugins (cfg.set == "oceanicnext") [ oceanicnext ]) ++
      (withPlugins cfg.transparent [ nvim-transparent ]);
    
    vim.configRC = ''
      set background=dark
      ${writeIf (cfg.set == "oceanicnext") ''
        colorscheme OceanicNext
      ''}
      ${writeIf (cfg.set == "tokyonight") ''
        colorscheme tokyonight-moon
      ''}
      ${writeIf (cfg.set == "catppuccin") ''
        colorscheme catppuccin-macchiato
      ''}
    '';

    vim.luaConfigRC = ''
      ${writeIf cfg.transparent ''
        -- Enable transparency
        require('transparent').setup()
      ''}
    '';
  };
}
