{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.colorscheme;
in {
  options.vim.colorscheme = {
    set = mkOption {
      type = types.enum ["catppuccin" "tokyonight" "oceanicnext" "gruvbox"];
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
    vim.startPlugins = with pkgs.neovimPlugins; [catppuccin tokyonight oceanicnext gruvbox nvim-transparent];

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
      ${writeIf (cfg.set == "gruvbox") ''
        colorscheme gruvbox
      ''}
    '';

    vim.luaConfigRC = ''
      -- Enable transparency plugin
      require('transparent').setup()
      map("n", "<leader>ut", "<cmd>TransparentToggle<cr>", { desc = "Toggle Transparency" })
    '';
  };
}
