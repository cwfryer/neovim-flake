{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.vim.editor;
in
{
  options.vim.editor = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable editor plugins";
    };
    enableTree = mkOption {
      type = types.bool;
      default = false;
      description = "Enable file tree";
    };
    improveSearchReplace = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-spectre search/replace";
    };
    enableTelescope = mkOption {
      type = types.bool;
      default = false;
      description = "Enable telescope";
    };
    movement = {
      enableFlit = mkOption {
        type = types.bool;
        default = false;
        description = "Enable flit movement";
      };
      enableLeap = mkOption {
        type = types.bool;
        default = false;
        description = "Enable leap movement";
      };
    };
    visuals = {
      enableGitSigns = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gitsigns visual git markers";
      };
      enableIlluminate = mkOption {
        type = types.bool;
        default = false;
        description = "Enable illuminate; highlights other refs of hovered word";
      };
      betterTODOComents = mkOption {
        type = types.bool;
        default = false;
        description = "Enable improved TODO comments";
      };
    };
    improveDiagnostics = mkOption {
      type = types.bool;
      default = false;
      description = "Enable improved diagnostics window";
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins; 
    [mini-bufremove] ++
    (withPlugins cfg.editor.enableTree [neo-tree]) ++
    (withPlugins cfg.editor.improveSearchReplace [nvim-spectre]) ++
    (withPlugins cfg.editor.enableTelescope [telescope]) ++
    (withPlugins cfg.editor.movement.enableFlit [flit]) ++
    (withPlugins cfg.editor.movement.enableLeap [leap]) ++
    (withPlugins cfg.editor.visuals.enableGitSigns [gitsigns]) ++
    (withPlugins cfg.editor.visuals.enableIlluminate [vim-illuminate]) ++
    (withPlugins cfg.editor.visuals.betterTODOCOments [todo-comments]) ++
    (withPlugins cfg.editor.improveDiagnostics [trouble]);

    vim.luaConfigRC = ''
    -- ---------------------------------------
    -- Editor Config
    -- ---------------------------------------
      ${writeIf cfg.editor.enableTree ''
      ''}
      ${writeIf cfg.editor.improveSearchReplace ''
      ''}
      ${writeIf cfg.editor.enableTelescope ''
      ''}
      ${writeIf cfg.editor.movement.enableFlit ''
      ''}
      ${writeIf cfg.editor.movement.enableLeap  ''
      ''}
      ${writeIf cfg.editor.visuals.enableGitSigns ''
      ''}
      ${writeIf cfg.editor.visuals.enableIlluminate ''
      ''}
      ${writeIf cfg.editor.visuals.betterTODOCOments ''
      ''}
      ${writeIf cfg.editor.improveDiagnostics ''
      ''}
    '';
  };
}
