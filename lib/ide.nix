{
  pkgs,
  lib,
  neovimBuilder,
  ...
}: let
  deepMerge = lib.attrsets.recursiveUpdate;

  cfg = {
    vim = {
      viAlias = false;
      vimAlias = true;
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
          completeFromBuffer = true;
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
        enableFloatingTerminal = true;
      };
      keys = {
        enable = true;
        whichKey.enable = true;
      };
      lsp = {
        enable = true;
        extras = {
          neoconf = true;
          neodev = false;
        };
        autoFormatting = true;
        languages = {
          lua.enable = true;
          lua.embedLSP = true;
          nix.enable = true;
          nix.embedLSP = true;
          rust.enable = true;
          rust.embedLSP = true;
          # Uncomment to enable
          go.enable = true;
          go.embedLSP = true;
          python.enable = true;
          python.embedLSP = true;
          typescript.enable = true;
          typescript.embedLSP = true;
          html.enable = true;
          html.embedLSP = true;
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
  nightly = {
    vim.neovim.package = pkgs.neovim-nightly;
  };
in {
  lazy = neovimBuilder {
    config = deepMerge cfg nightly;
  };

  full = neovimBuilder {
    config = deepMerge cfg nightly;
  };
}
