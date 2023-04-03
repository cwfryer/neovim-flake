{ pkgs, lib, neovimBuilder, ... }:

let
  deepMerge = lib.attrsets.recursiveUpdate;

  cfg = {
    vim = {
      core = {
      };
      neovim = {};
      coding = {
        enable = true;
        snippets = {
          enable = true;
          useFriendlySnippets = true;
        };
        completion = {
          enable = true;
          useSuperTab = true;
          completeFromLSP = true;
          compelteFromBuffer = true;
          completeFromPath = true;
          completeFromLuaSnip = true;
        };
        helpers = {
          autoPair = true;
          surround = true;
          comment = {
            enable = true;
            useTreeSitterContext = true;
          };
          betterAISelection = true;
        };
      };
      colorscheme = {
        set = "oceanicnext";
        transparent = true;
      };
      editor = {
        enable = true;
        enableTree = true;
        improveSearchReplace = true;
        enableTelescope = true;
        movement = {
          enableFlit = true;
          enableLeap = true;
        };
        visuals = {
          enableGitSigns = true;
          enableIlluminate = true;
          betterTODOComments = true;
        };
        improveDiagnostics = true;
      };
      keys = {};
      lsp = {
        enable = true;
        extra = {
          neoconf = true;
          neodev = false;
        };
        autoFormatting = true;
        languages = {
          lua = true;
          nix = true;
          rust = true;
          # Uncomment to enable
          # go = true;
          # pyton = true;
          # typescript = true;
        };
      };
      treesitter = {
        enable = true;
        textobjects = true;
      };
      ui = {
        enable = true;
        uiTweaks = {
          system = "noice.nvim";
          interfaces = true;
          icons = true;
          components = true;
          indents = true;
        };
        uiAdditions = {
          bufferline = true;
          lualine = {
            enable = true;
            improveContext = true;
          };
          indents = true;
          dashboard = "mini.starter";
        };
      };
      util = {
        enable = true;
        sessions = true;
      };
    };
  };
in
{
  lazy = neovimBuilder {
    config = deepMerge cfg;
  };

  full = neovimBuilder {
    config = deepMerge cfg;
  };

}
