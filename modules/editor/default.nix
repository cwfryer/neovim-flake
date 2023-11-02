{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.editor;
in {
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
      betterTODOComments = mkOption {
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
    enableFloatingTerminal = mkOption {
      type = types.bool;
      default = true;
      description = "Enable toggle-able floating terminal";
    };
  };
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.neovimPlugins;
      [mini-bufremove]
      ++ (withPlugins cfg.enableTree [neo-tree])
      ++ (withPlugins cfg.improveSearchReplace [nvim-spectre])
      ++ (withPlugins cfg.enableTelescope [telescope])
      ++ (withPlugins cfg.movement.enableFlit [flit])
      ++ (withPlugins cfg.movement.enableLeap [leap])
      ++ (withPlugins cfg.visuals.enableGitSigns [gitsigns])
      ++ (withPlugins cfg.visuals.enableIlluminate [vim-illuminate])
      ++ (withPlugins cfg.visuals.betterTODOComments [todo-comments])
      ++ (withPlugins cfg.improveDiagnostics [trouble])
      ++ (withPlugins cfg.improveDiagnostics [toggleterm]);

    vim.luaConfigRC = ''
      -- ---------------------------------------
      -- Editor Config
      -- ---------------------------------------

      -- Better buffer closing
      require("mini.bufremove").setup()
      map("n","<leader>bd",function() require("mini.bufremove").delete(0, false) end, {desc = "Delete Buffer"})
      map("n","<leader>bD",function() require("mini.bufremove").delete(0, true) end, {desc = "Delete Buffer (force)"})
      ${writeIf cfg.enableTree ''
        -- NeoTree filetree setup
        vim.g.neo_tree_remove_legacy_commands = 1
        require("neo-tree").setup({
          filesystem = {
            bind_to_cwd = false,
            follow_current_file.enabled,
            use_libuv_file_watcher = true,
          },
          window = {
            width = 30,
            mappings = {
              ["<space>"] = "none",
            },
          },
          default_component_configs = {
            indent = {
              with_expanders = true,
              expander_collapsed = "",
              expander_expanded = "",
              expander_highlight = "NeoTreeExpander",
            },
          },
        })

        -- NeoTree keys
        map(
          "n",
          "<leader>fe",
          function()
            require("neo-tree.command").execute({ toggle = true })
          end,
          { desc = "Explorer NeoTree (root dir)" }
        )
        map(
          "n",
          "<leader>fE",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
          end,
          { desc = "Explorer NeoTree (cwd)" }
        )
        map("n", "<leader>e", "<leader>fe", { desc = "Explorer NeoTree (root dir)", remap = true })
        map("n", "<leader>E", "<leader>fE", { desc = "Explorer NeoTree (cwd)", remap = true })

        -- NeoTree autocmd
        vim.api.nvim_create_autocmd("TermClose", {
          pattern = "*gitui",
          callback = function()
            if package.loaded["neo-tree.sources.git_status"] then
              require("neo-tree.sources.git_status").refresh()
            end
          end,
        })
      ''}
      ${writeIf cfg.improveSearchReplace ''
        -- Spectre find/replace setup
        require("spectre").setup()
        -- Spectre keys
        map("n", "<leader>sr", function() require("spectre").open() end, {desc="Replace in files (spectre)"})
      ''}
      ${writeIf cfg.enableTelescope ''
        -- Telescope setup
        require("telescope").setup({
          defaults = {
            prompt_prefix = " ",
            selection_caret = " ",
            mappings = {
              i = {
                ${writeIf cfg.improveDiagnostics ''
          ["<c-t>"] = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
          end,
          ["<a-t>"] = function(...)
            return require("trouble.providers.telescope").open_selected_with_trouble(...)
          end,
        ''}
                ["<a-i>"] = function()
                  return require("telescope.builtin").find_files({no_ignore = true})
                end,
                ["<a-h>"] = function()
                  return require("telescope.builtin").find_files({hidden = true})
                end,
                ["<C-Down>"] = function(...)
                  return require("telescope.actions").cycle_history_next(...)
                end,
                ["<C-Up>"] = function(...)
                  return require("telescope.actions").cycle_history_prev(...)
                end,
                ["<C-f>"] = function(...)
                  return require("telescope.actions").preview_scrolling_down(...)
                end,
                ["<C-b>"] = function(...)
                  return require("telescope.actions").preview_scrolling_up(...)
                end,
              },
              n = {
                ["q"] = function(...)
                  return require("telescope.actions").close(...)
                end,
              },
            },
          },
        })
        -- Telescope keys
        map("n","<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", { desc = "Switch Buffer" })
        map("n","<leader>/", function() require("telescope.builtin").live_grep() end, { desc = "Grep (root dir)" })
        map("n","<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command History" })
        map("n","<leader><space>", function() require("telescope.builtin").fd({root}) end, { desc = "Find Files (root dir)" })
        -- Telescope find keys
        map("n","<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
        map("n","<leader>ff", function() require("telescope.builtin").fd({root}) end, { desc = "Find Files (root dir)" })
        map("n","<leader>fF", function() require("telescope.builtin").fd({cwd}) end, { desc = "Find Files (cwd)" })
        map("n","<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent" })
        map("n","<leader>fR", function() require("telescope.builtin").oldfiles({cwd = vim.loop.cwd()}) end, { desc = "Recent" })
        -- Telescope git keys
        map("n","<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "commits" })
        map("n","<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "status" })
        -- Telescope search keys
        map("n","<leader>sa", "<cmd>Telescope autocommands<cr>", { desc = "Auto Commands" })
        map("n","<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer" })
        map("n","<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command History" })
        map("n","<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" })
        map("n","<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document Diagnostics" })
        map("n","<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace Diagnostics" })
        map("n","<leader>sg", function() require("telescope.builtin").live_grep({root}) end, { desc = "Grep (root dir)" })
        map("n","<leader>sG", function() require("telescope.builtin").live_grep({cwd}) end, { desc = "Grep (cwd)" })
        map("n","<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" })
        map("n","<leader>sH", "<cmd>Telescope highlights<cr>", { desc = "Search Highlight Groups" })
        map("n","<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
        map("n","<leader>sM", "<cmd>Telescope man_pages<cr>", { desc = "Man Pages" })
        map("n","<leader>sm", "<cmd>Telescope marks<cr>", { desc = "Jump to Mark" })
        map("n","<leader>so", "<cmd>Telescope vim_options<cr>", { desc = "Options" })
        map("n","<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Resume" })
        map("n","<leader>sw", function() require("telescope.builtin").grep_string({root}) end, { desc = "Word (root dir)" })
        map("n","<leader>sW", function() require("telescope.builtin").grep_string({cwd}) end, { desc = "Word (cwd)" })
        map("n","<leader>uC", function() require("telescope.builtin").colorscheme() end, { desc = "Colorscheme" })
        map(
          "n",
          "<leader>ss",
          function()
            require("telescope.builtin").lsp_document_symbols({
              symbols = {
                "Class",
                "Function",
                "Method",
                "Constructor",
                "Interface",
                "Module",
                "Struct",
                "Trait",
                "Field",
                "Property",
              },
            })
          end,
          { desc = "Goto Symbol" }
        )
        map(
          "n",
          "<leader>sS",
          function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols({
              symbols = {
                "Class",
                "Function",
                "Method",
                "Constructor",
                "Interface",
                "Module",
                "Struct",
                "Trait",
                "Field",
                "Property",
              },
            })
          end,
          { desc = "Goto Symbol (Workspace)" }
        )
      ''}
      ${writeIf cfg.movement.enableFlit ''
        -- Movement setup: Flit
        require("flit").setup({
          keys = { f = 'f', F = 'F', t = 't', T = 'T' },
          labeled_modes = "nx",
        })
      ''}
      ${writeIf cfg.movement.enableLeap ''
        -- Movement setup: Leap
        require("leap").add_default_mappings(true)
        vim.keymap.del({"x","o"}, "x")
        vim.keymap.del({"x","o"}, "X")
      ''}
      ${writeIf cfg.visuals.enableGitSigns ''
        -- Gitsigns setup
        require("gitsigns").setup({
          signs = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "▎" },
            untracked = { text = "▎" },
          },
          on_attach = function(buffer)
            local gs = package.loaded.gitsigns
            local function gsmap(mode, l, r, desc)
              vim.keymap.set(mode, l, r, {buffer = buffer, desc = desc})
            end

            gsmap("n", "]h", gs.next_hunk, "Next Hunk")
            gsmap("n", "[h", gs.prev_hunk, "Prev Hunk")
            gsmap({"n","v"}, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
            gsmap({"n","v"}, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
            gsmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
            gsmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
            gsmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
            gsmap("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
            gsmap("n", "<leader>ghb", function() gs.blame_line({full=true}) end, "Blame Line")
            gsmap("n", "<leader>ghd", gs.diffthis, "Diff This")
            gsmap("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
            gsmap({"o","x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
          end,
        })
      ''}
      ${writeIf cfg.visuals.enableIlluminate ''
        -- Highlight same word in buffer
        require("illuminate").configure({
          delay = 200,
        })
        local function imap(key, dir, buffer)
          vim.keymap.set("n", key, function()
            require("illuminate")["goto_" .. dir .. "_reference"](false)
          end, {desc = dir:sub(1, 1):upper() .. dir:sub(2) .. "Reference", buffer = buffer })
        end
        imap("]]", "next")
        imap("[[", "prev")

        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            local buffer = vim.api.nvim_get_current_buf()
            imap("]]", "next", buffer)
            imap("[[", "prev", buffer)
          end,
        })
      ''}
      ${writeIf cfg.visuals.betterTODOComments ''
        -- Highlight todo comments
        require("todo-comments").setup()
        map("n","]t", function() require("todo-comments").jump_next() end, {desc="Next todo comment"})
        map("n","[t", function() require("todo-comments").jump_prev() end, {desc="Previous todo comment"})
        map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", {desc="Todo (Trouble)"})
        map("n", "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", {desc="Todo/Fix/Fixme (Trouble)"})
        map("n", "<leader>st", "<cmd>TodoTelescope<cr>", {desc="Todo"})
        map("n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", {desc="Todo/Fix/Fixme"})
      ''}
      ${writeIf cfg.improveDiagnostics ''
        -- Better diagnostics window
        require("trouble").setup({
          use_diagnostic_signs = true,
        })
        -- trouble.nvim keys
        map("n","<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", {desc="Document Diagnostics(Trouble)"})
        map("n","<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", {desc="Workspace Diagnostics(Trouble)"})
        map("n","<leader>xL", "<cmd>TroubleToggle loclist<cr>", {desc="Location List (Trouble)"})
        map("n","<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", {desc="Quickfix List (Trouble)"})
        map(
          "n",
          "[q",
          function()
            if require("trouble").is_open() then
              require("trouble").previous({ skip_groups = true, jump = true })
            else
              vim.cmd.cprev()
            end
          end,
          { desc = "Previous trouble/quickfix item" }
        )
        map(
          "n",
          "]q",
          function()
            if require("trouble").is_open() then
              require("trouble").next({ skip_groups = true, jump = true })
            else
              vim.cmd.cnext()
            end
          end,
          { desc = "Next trouble/quickfix item" }
        )
      ''}
      ${writeIf cfg.enableFloatingTerminal ''
        -- Toggleterm floating terminal
        require("toggleterm").setup{}
        -- Toggleterm keys
        -- keys are setup in the basic config section
      ''}
    '';
  };
}
