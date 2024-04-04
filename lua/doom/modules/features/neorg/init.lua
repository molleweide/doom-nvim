-- local utils = require("doom.utils")

local neorg = {}

-- https://github.com/max397574/neorg-kanban

local doom_root = require("doom.core.system").doom_root

-- NOTE: this might be solution to installing norg parser on macos:
--  https://github.com/nvim-neorg/tree-sitter-norg/issues/7

neorg.settings = {
  load = {
    ["core.defaults"] = {},
    ["core.keybinds"] = {
      config = {
        default_keybinds = true,
        neorg_leader = ",o",
      },
    },
    ["core.concealer"] = {},
    ["core.qol.toc"] = {},
    ["core.dirman"] = {
      config = {
        workspaces = {
          main = "~/neorg",
          test = "~/neorg_test",
          -- gtd = "~/neorg/gtd",
          doom_docs = string.format("%s/doc", doom_root),
        },
        autodetect = true,
        autochdir = true,
      },
    },
    ["core.esupports.metagen"] = {
      config = { type = "auto" },
    },
    ["core.export"] = {},
    ["core.export.markdown"] = {
      config = { extensions = "all" },
    },
    -- ["core.gtd.base"] = {
    --   config = {
    --     workspace = "gtd",
    --   },
    -- },
    ["core.integrations.telescope"] = {},
    ["core.integrations.nvim-cmp"] = {},
    ["core.presenter"] = {
      config = {
        zen_mode = "truezen",
      },
    },
    ["core.journal"] = {
      config = {
        workspace = "main",
        journal_folder = "journal",
      },
    },
  },
}

neorg.packages = {
  ["neorg"] = {
    "nvim-neorg/neorg",
    -- commit = {
    --   ["nvim-0.7"] = "d93126cfcc2b5f90c063676f8669fed9b0806bcd",
    --   ["latest"] = "aa613122f82ca7485b7055937a742b709ed3c576",
    -- },
    cmd = "Neorg",
    dependencies = {
      "luarocks.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neorg/neorg-telescope",
      -- , "nvim-treesitter/nvim-treesitter",
    },
  },
  -- ["neorg-telescope"] = { "nvim-neorg/neorg-telescope", after = { "telescope.nvim" } },
}

neorg.configs = {}
neorg.configs["neorg"] = function()
  require("neorg").setup(doom.features.neorg.settings)

  -- these are found in the example config at github
  vim.wo.foldlevel = 99
  vim.wo.conceallevel = 2
end
neorg.configs["neorg-telescope"] = function()
  require("telescope").load_extension("neorg")
end

-- TODO: add norg bindings > look at Max's config

-- neorg.autocmds = {
--   {
--     "BufWinEnter",
--     "*.norg",
--     function()
--       -- Manually add norg parser to be always up-to-date
--       -- and add additional (opt-in) neorg parsers
--       local parsers = require("nvim-treesitter.parsers").get_parser_configs()
--
--       parsers.norg = {
--         install_info = {
--           url = "https://github.com/nvim-neorg/tree-sitter-norg",
--           files = { "src/parser.c", "src/scanner.cc" },
--           branch = "main",
--         },
--       }
--       parsers.norg_meta = {
--         install_info = {
--           url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
--           files = { "src/parser.c" },
--           branch = "main",
--         },
--       }
--       parsers.norg_table = {
--         install_info = {
--           url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
--           files = { "src/parser.c" },
--           branch = "main",
--         },
--       }
--
--       vim.defer_fn(function()
--         local ensure_installed = require("nvim-treesitter.install").ensure_installed
--         ensure_installed("norg")
--         ensure_installed("norg_meta")
--         ensure_installed("norg_table")
--       end, 0)
--     end,
--   },
-- }

-- If you're using the automatic keybind generation provided by Neorg you can
-- start using <C-s> (search linkable elements) in normal mode and <C-l>
-- (insert link) in insert mode. If you're not using the automatic keybind
-- generation, be sure to make Neorg use those keys:
--
-- local neorg_callbacks = require("neorg.callbacks")
--
-- neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
--     -- Map all the below keybinds only when the "norg" mode is active
--     keybinds.map_event_to_mode("norg", {
--         n = { -- Bind keys in normal mode
--             { "<C-s>", "core.integrations.telescope.find_linkable" },
--         },
--
--         i = { -- Bind in insert mode
--             { "<C-l>", "core.integrations.telescope.insert_link" },
--         },
--     }, {
--         silent = true,
--         noremap = true,
--     })
-- end)

-- todo: telescope find neorg files in notes -> only dirs > on enter create new file in dir.

neorg.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "o",
        name = "+open/close",
        {
          "n",
          name = "+neorg",
          {
            { "c", ":Neorg ", name = "neorg workspace main", options = { silent = false } },
            { "d", ":Neorg workspace main<cr>", name = "neorg workspace main" },
            { "G", ":Neorg workspace gtd<cr>", name = "neorg gtd" },
            { "E", ":Neorg workspace example_gtd<cr>", name = "neorg example" },
            { "g", ":Neorg gtd ", name = "neorg gtd <insert>" },
            { "c", ":Neorg gtd capture<cr>", name = "neorg capture" },
            { "e", ":Neorg gtd edit<cr>", name = "neorg gtd edit" },
            { "v", ":Neorg gtd views<cr>", name = "neorg gtd views" },
            { "t", ":Neorg journal today<cr>", name = "neorg journal today" },
            { "n", ":Neorg present<cr>", name = "neorg present" },
            {
              "f",
              function()
                require("telescope.builtin").find_files({ cwd = "~/neorg" })
              end,
              name = "Search Neorg notes/files",
            },
            -- Telescope neorg find_linkable
            -- Telescope neorg search_headings
            -- Telescope neorg find_project_tasks
            -- Telescope neorg find_context_tasks
            -- Telescope neorg find_aof_tasks
            -- Telescope neorg find_aof_project_tasks
          },
        },
      },
    },
  },
}

return neorg
