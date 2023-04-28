{
  description = "Neovim Flake by Casey Fryer";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    #-------------------------------------
    # Coding Plugins
    #-------------------------------------
    lua-snip = {
      url = github:L3MON4D3/LuaSnip;
      flake = false;
    };
    friendly-snippets = {
      url = github:rafamadriz/friendly-snippets;
      flake = false;
    };
    nvim-cmp = {
      url = github:hrsh7th/nvim-cmp;
      flake = false;
    };
    cmp-nvim-lsp = {
      url = github:hrsh7th/cmp-nvim-lsp;
      flake = false;
    };
    cmp-buffer = {
      url = github:hrsh7th/cmp-buffer;
      flake = false;
    };
    cmp-path = {
      url = github:hrsh7th/cmp-path;
      flake = false;
    };
    cmp-luasnip = {
      url = github:saadparwaiz1/cmp_luasnip;
      flake = false;
    };
    lspkind = {
      url = github:onsails/lspkind.nvim;
      flake = false;
    };
    mini-pairs = {
      url = github:echasnovski/mini.pairs;
      flake = false;
    };
    mini-surround = {
      url = github:echasnovski/mini.surround;
      flake = false;
    };
    nvim-ts-commentstring = {
      url = github:JoosepAlviste/nvim-ts-context-commentstring;
      flake = false;
    };
    mini-comment = {
      url = github:echasnovski/mini.comment;
      flake = false;
    };
    mini-ai = {
      url = github:echasnovski/mini.ai;
      flake = false;
    };

    #-------------------------------------
    # Colorscheme Plugins
    #-------------------------------------
    tokyonight = {
      url = github:folke/tokyonight.nvim;
      flake = false;
    };
    catppuccin = {
      url = github:catppuccin/nvim;
      flake = false;
    };
    oceanicnext = {
      url = github:mhartington/oceanic-next;
      flake = false;
    };
    nvim-transparent = {
      url = github:xiyaowong/nvim-transparent;
      flake = false;
    };

    #-------------------------------------
    # Editor Plugins
    #-------------------------------------
    neo-tree = {
      url = github:nvim-neo-tree/neo-tree.nvim;
      flake = false;
    };
    nvim-spectre = {
      url = github:nvim-pack/nvim-spectre;
      flake = false;
    };
    telescope = {
      url = github:nvim-telescope/telescope.nvim;
      flake = false;
    };
    flit = {
      url = github:ggandor/flit.nvim;
      flake = false;
    };
    leap = {
      url = github:ggandor/leap.nvim;
      flake = false;
    };
    which-key = {
      url = github:folke/which-key.nvim;
      flake = false;
    };
    gitsigns = {
      url = github:lewis6991/gitsigns.nvim;
      flake = false;
    };
    vim-illuminate = {
      url = github:RRethy/vim-illuminate;
      flake = false;
    };
    mini-bufremove = {
      url = github:echasnovski/mini.bufremove;
      flake = false;
    };
    trouble = {
      url = github:folke/trouble.nvim;
      flake = false;
    };
    todo-comments = {
      url = github:folke/todo-comments.nvim;
      flake = false;
    };
    toggleterm = {
      url = github:akinsho/toggleterm.nvim;
      flake = false;
    };

    #-------------------------------------
    # LSP Plugins
    #-------------------------------------
    nvim-lspconfig = {
      url = github:neovim/nvim-lspconfig;
      flake = false;
    };
    neoconf = {
      url = github:folke/neoconf.nvim;
      flake = false;
    };
    neodev = {
      url = github:folke/neodev.nvim;
      flake = false;
    };
    mason-lspconfig = {
      url = github:williamboman/mason-lspconfig.nvim;
      flake = false;
    };
    null-ls = {
      url = github:jose-elias-alvarez/null-ls.nvim;
      flake = false;
    };
    mason = {
      url = github:williamboman/mason.nvim;
      flake = false;
    }; # TODO is this needed?
    crates-nvim = {
      url = github:Saecki/crates.nvim;
      flake = false;
    };
    rust-tools = {
      url = github:simrat39/rust-tools.nvim;
      flake = false;
    };
    inc-rename = {
      url = github:smjonas/inc-rename.nvim;
      flake = false;
    };

    #-------------------------------------
    # Treesitter Plugins
    #-------------------------------------
    nvim-treesitter = {
      url = github:nvim-treesitter/nvim-treesitter;
      flake = false;
    };
    nvim-treesitter-playground = {
      url = github:nvim-treesitter/playground;
      flake = false;
    };
    nvim-treesitter-textobjects = {
      url = github:nvim-treesitter/nvim-treesitter-textobjects;
      flake = false;
    };

    #-------------------------------------
    # UI Plugins
    #-------------------------------------
    nvim-notify = {
      url = github:rcarriga/nvim-notify;
      flake = false;
    };
    dressing = {
      url = github:stevearc/dressing.nvim;
      flake = false;
    };
    bufferline = {
      url = github:akinsho/bufferline.nvim;
      flake = false;
    };
    lualine = {
      url = github:nvim-lualine/lualine.nvim;
      flake = false;
    };
    indent-blankline = {
      url = github:lukas-reineke/indent-blankline.nvim;
      flake = false;
    };
    mini-indentscope = {
      url = github:echasnovski/mini.indentscope;
      flake = false;
    };
    noice = {
      url = github:folke/noice.nvim;
      flake = false;
    };
    nui = {
      url = github:MunifTanjim/nui.nvim;
      flake = false;
    };
    alpha = {
      url = github:goolord/alpha-nvim;
      flake = false;
    };
    nvim-navic = {
      url = github:SmiteshP/nvim-navic;
      flake = false;
    };
    nvim-web-devicons = {
      url = github:nvim-tree/nvim-web-devicons;
      flake = false;
    };

    #-------------------------------------
    # Utility Plugins
    #-------------------------------------
    persistence = {
      url = github:folke/persistence.nvim;
      flake = false;
    };
    plenary = {
      url = github:nvim-lua/plenary.nvim;
      flake = false;
    };

    #-------------------------------------
    # Extra Plugins
    #-------------------------------------
    # prettier = {
    # 	url = github:;
    # 	flake = false;
    # };
    mini-starter = {
      url = github:echasnovski/mini.starter;
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        plugins = let
          f = xs: pkgs.lib.attrsets.filterAttrs (k: v: !builtins.elem k xs);

          nonPluginInputNames = [
            "self"
            "nixpkgs"
            "flake-utils"
            "neovim-nightly-overlay"
          ];
        in
          builtins.attrNames (f nonPluginInputNames inputs);

        lib = import ./lib {inherit pkgs inputs plugins;};

        inherit (lib) neovimBuilder;

        pluginOverlay = lib.buildPluginOverlay;

        libOverlay = f: p: {
          lib = p.lib.extend (_: _: {
            inherit (lib) mkVimBool withAttrSet withPlugins writeIf;
          });
        };

        neovimOverlay = f: p: {
          neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
        };

        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
          overlays = [libOverlay pluginOverlay neovimOverlay];
        };

        default-ide = pkgs.callPackage ./lib/ide.nix {
          inherit pkgs neovimBuilder;
        };
      in rec {
        apps = rec {
          nvim = {
            type = "app";
            program = "${packages.default}/bin/nvim";
          };

          default = nvim;
        };

        overlays.default = f: p: {
          inherit neovimBuilder;
          inherit (pkgs) neovim-nightly neovimPlugins;
        };

        nixosModules.hm = {
          imports = [
            ./lib/hm.nix
            {nixpkgs.overlays = [overlays.default];}
          ];
        };

        packages = {
          default = default-ide.full.neovim;

          ide = default-ide.full.neovim; # my personal config
          lazy = default-ide.lazy.neovim; # default lazyvim config

          # Neovim configuration files
          ide-neovim-rc = default-ide.full.neovimRC;
          lazy-neovim-rc = default-ide.lazy.neovimRC;

          # Lua configuration files
          ide-lua-rc = default-ide.full.luaRC;
          lazy-lua-rc = default-ide.lazy.luaRC;
        };
      }
    );
}
