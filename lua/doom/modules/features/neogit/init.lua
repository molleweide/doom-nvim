local neogit = {}

-- neogit.settings = {
--   -- override/add mappings
--   mappings = {
--     -- modify status buffer mappings
--     status = {
--       -- Removes the default mapping of "s"
--       ["s"] = "a",
--       ["S"] = "A",
--     },
--   },
-- }

neogit.settings = {}

neogit.packages = {
  ["neogit"] = {
    "TimUntersberger/neogit",
    commit = "05386ff1e9da447d4688525d64f7611c863f05ca",
    cmd = "Neogit",
    opt = true,
  },
}

-- n.packages = {
--   m.neogit.packages["neogit"][1] = gh .. "TimUntersberger/neogit"
-- }

-- return function()
--   local neogit = require("neogit")
--
--   neogit.setup {
--     disable_signs = false,
--     disable_hint = false,
--     disable_context_highlighting = false,
--     disable_commit_confirmation = false,
--     auto_refresh = true,
--     disable_builtin_notifications = false,
--     commit_popup = {
--       kind = "split",
--     },
--     -- Change the default way of opening neogit
--     kind = "tab",
--     -- customize displayed signs
--     signs = {
--       -- { CLOSED, OPENED }
--       section = { ">", "v" },
--       item = { ">", "v" },
--       hunk = { "", "" },
--     },
--     integrations = {
--       -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
--       -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
--       --
--       -- Requires you to have `sindrets/diffview.nvim` installed.
--       -- use {
--       --   'TimUntersberger/neogit',
--       --   requires = {
--       --     'nvim-lua/plenary.nvim',
--       --     'sindrets/diffview.nvim'
--       --   }
--       -- }
--       --
--       diffview = true
--     },
--     -- Setting any section to `false` will make the section not render at all
--     sections = {
--       untracked = {
--         folded = false
--       },
--       unstaged = {
--         folded = false
--       },
--       staged = {
--         folded = false
--       },
--       stashes = {
--         folded = true
--       },
--       unpulled = {
--         folded = true
--       },
--       unmerged = {
--         folded = false
--       },
--       recent = {
--         folded = true
--       },
--     },
--     -- override/add mappings
--     mappings = {
--       -- modify status buffer mappings
--       status = {
--         -- Adds a mapping with "B" as key that does the "BranchPopup" command
--         ["B"] = "BranchPopup",
--         -- Removes the default mapping of "s"
--         ["s"] = "a",
--         ["S"] = "A",
--       }
--     }
--   }
-- end

-- -- NEOGIT
-- -- :Neogit " uses tab
-- -- :Neogit kind=<kind> " override kind
-- -- :Neogit cwd=<cwd> " override cwd
-- -- :Neogit commit" open commit popup
neogit.configs = {}
neogit.configs["neogit"] = function()
  require("neogit").setup(doom.features.neogit.settings)
end

-- neogit.binds = {
--   "<leader>",
--   name = "+prefix",
--   {
--     {
--       "o",
--       name = "+open/close",
--       {
--         { "g", "<cmd>Neogit<CR>", name = "Neogit" },
--       },
--     },
--     {
--       "g",
--       name = "+git",
--       {
--         { "g", "<cmd>Neogit<CR>", name = "Open neogit" },
--       },
--     },
--   },
-- }

neogit.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "o",
        name = "+open/close",
        {
          { "g", "<cmd>Neogit<CR>", name = "Neogit" },
        },
      },
      {
        "g",
        name = "+git",
        {
          { "c", name = "+commits", {
              { 'c', '<cmd>Neogit commit<CR>', name = "neogit commit"},
            }
          },
          { "n", "<cmd>Neogit<CR>", name = "Open Neogit" },
        },
      },
    },
  },
}

return neogit
