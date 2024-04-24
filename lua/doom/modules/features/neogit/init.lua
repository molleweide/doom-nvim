local neogit = {}

-- NOTE: How to keep `leap` on `s` mapping inside Neogit
-- https://github.com/NeogitOrg/neogit/issues/564
--
--
--
--
--
--
--
--
--

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

neogit.settings = {
  -- Hides the hints at the top of the status buffer
  disable_hint = false,
  -- Disables changing the buffer highlights based on where the cursor is.
  disable_context_highlighting = false,
  -- Disables signs for sections/items/hunks
  disable_signs = false,
  -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
  -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
  -- normal mode.
  disable_insert_on_commit = "auto",
  -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
  -- events.
  filewatcher = {
    interval = 1000,
    enabled = true,
  },
  -- "ascii"   is the graph the git CLI generates
  -- "unicode" is the graph like https://github.com/rbong/vim-flog
  graph_style = "ascii",
  -- Used to generate URL's for branch popup action "pull request".
  git_services = {
    ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
    ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
    ["gitlab.com"] =
    "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
  },
  -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
  -- sorter instead. By default, this function returns `nil`.
  telescope_sorter = function()
    return require("telescope").extensions.fzf.native_fzf_sorter()
  end,
  -- Persist the values of switches/options within and across sessions
  remember_settings = true,
  -- Scope persisted settings on a per-project basis
  use_per_project_settings = true,
  -- Table of settings to never persist. Uses format "Filetype--cli-value"
  ignored_settings = {
    "NeogitPushPopup--force-with-lease",
    "NeogitPushPopup--force",
    "NeogitPullPopup--rebase",
    "NeogitCommitPopup--allow-empty",
    "NeogitRevertPopup--no-edit",
  },
  -- Configure highlight group features
  highlight = {
    italic = true,
    bold = true,
    underline = true,
  },
  -- Set to false if you want to be responsible for creating _ALL_ keymappings
  use_default_keymaps = true,
  -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
  -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
  auto_refresh = true,
  -- Value used for `--sort` option for `git branch` command
  -- By default, branches will be sorted by commit date descending
  -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
  -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
  sort_branches = "-committerdate",
  -- Change the default way of opening neogit
  kind = "tab",
  -- Disable line numbers and relative line numbers
  disable_line_numbers = true,
  -- The time after which an output console is shown for slow running commands
  console_timeout = 2000,
  -- Automatically show console if a command takes more than console_timeout milliseconds
  auto_show_console = true,
  status = {
    recent_commit_count = 10,
  },
  commit_editor = {
    kind = "auto",
  },
  commit_select_view = {
    kind = "tab",
  },
  commit_view = {
    kind = "vsplit",
    verify_commit = os.execute("which gpg") == 0, -- Can be set to true or false, otherwise we try to find the binary
  },
  log_view = {
    kind = "tab",
  },
  rebase_editor = {
    kind = "auto",
  },
  reflog_view = {
    kind = "tab",
  },
  merge_editor = {
    kind = "auto",
  },
  tag_editor = {
    kind = "auto",
  },
  preview_buffer = {
    kind = "split",
  },
  popup = {
    kind = "split",
  },
  signs = {
    -- { CLOSED, OPENED }
    hunk = { "", "" },
    item = { ">", "v" },
    section = { ">", "v" },
  },
  -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
  integrations = {
    -- If enabled, use telescope for menu selection rather than vim.ui.select.
    -- Allows multi-select and some things that vim.ui.select doesn't.
    telescope = nil,
    -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `diffview`.
    -- The diffview integration enables the diff popup.
    --
    -- Requires you to have `sindrets/diffview.nvim` installed.
    diffview = nil,

    -- If enabled, uses fzf-lua for menu selection. If the telescope integration
    -- is also selected then telescope is used instead
    -- Requires you to have `ibhagwan/fzf-lua` installed.
    fzf_lua = nil,
  },
  sections = {
    -- Reverting/Cherry Picking
    sequencer = {
      folded = false,
      hidden = false,
    },
    untracked = {
      folded = false,
      hidden = false,
    },
    unstaged = {
      folded = false,
      hidden = false,
    },
    staged = {
      folded = false,
      hidden = false,
    },
    stashes = {
      folded = true,
      hidden = false,
    },
    unpulled_upstream = {
      folded = true,
      hidden = false,
    },
    unmerged_upstream = {
      folded = false,
      hidden = false,
    },
    unpulled_pushRemote = {
      folded = true,
      hidden = false,
    },
    unmerged_pushRemote = {
      folded = false,
      hidden = false,
    },
    recent = {
      folded = true,
      hidden = false,
    },
    rebase = {
      folded = true,
      hidden = false,
    },
  },
  mappings = {
    commit_editor = {
      ["q"] = "Close",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    rebase_editor = {
      ["p"] = "Pick",
      ["r"] = "Reword",
      ["e"] = "Edit",
      ["s"] = "Squash",
      ["f"] = "Fixup",
      ["x"] = "Execute",
      ["d"] = "Drop",
      ["b"] = "Break",
      ["q"] = "Close",
      ["<cr>"] = "OpenCommit",
      ["gk"] = "MoveUp",
      ["gj"] = "MoveDown",
      ["<c-c><c-c>"] = "Submit",
      ["<c-c><c-k>"] = "Abort",
    },
    finder = {
      ["<cr>"] = "Select",
      ["<c-c>"] = "Close",
      ["<esc>"] = "Close",
      ["<c-n>"] = "Next",
      ["<c-p>"] = "Previous",
      ["<down>"] = "Next",
      ["<up>"] = "Previous",
      ["<tab>"] = "MultiselectToggleNext",
      ["<s-tab>"] = "MultiselectTogglePrevious",
      ["<c-j>"] = "NOP",
    },
    -- Setting any of these to `false` will disable the mapping.
    popup = {
      ["?"] = "HelpPopup",
      ["A"] = "CherryPickPopup",
      ["D"] = "DiffPopup",
      ["M"] = "RemotePopup",
      ["P"] = "PushPopup",
      ["X"] = "ResetPopup",
      ["Z"] = "StashPopup",
      ["b"] = "BranchPopup",
      ["c"] = "CommitPopup",
      ["f"] = "FetchPopup",
      ["l"] = "LogPopup",
      ["m"] = "MergePopup",
      ["p"] = "PullPopup",
      ["r"] = "RebasePopup",
      ["v"] = "RevertPopup",
      ["w"] = "WorktreePopup",
    },
    status = {
      -- Make room for s/S to be used with Leap.
      ["a"] = "Stage",
      ["s"] = false,
      ["<c-a>"] = "StageUnstaged",
      ["S"] = false,

      ["q"] = "Close",
      ["I"] = "InitRepo",
      ["1"] = "Depth1",
      ["2"] = "Depth2",
      ["3"] = "Depth3",
      ["4"] = "Depth4",
      ["<tab>"] = "Toggle",
      ["x"] = "Discard",

      ["<c-s>"] = "StageAll",
      ["u"] = "Unstage",
      ["U"] = "UnstageStaged",
      ["$"] = "CommandHistory",
      ["#"] = "Console",
      ["Y"] = "YankSelected",
      ["<c-r>"] = "RefreshBuffer",
      ["<enter>"] = "GoToFile",
      ["<c-v>"] = "VSplitOpen",
      ["<c-x>"] = "SplitOpen",
      ["<c-t>"] = "TabOpen",
      ["{"] = "GoToPreviousHunkHeader",
      ["}"] = "GoToNextHunkHeader",
    },
  },
}

-- {
--   "NeogitOrg/neogit",
--   dependencies = {
--     "nvim-lua/plenary.nvim",         -- required
--     "sindrets/diffview.nvim",        -- optional - Diff integration
--
--     -- Only one of these is needed, not both.
--     "nvim-telescope/telescope.nvim", -- optional
--     "ibhagwan/fzf-lua",              -- optional
--   },
--   config = true
-- }

neogit.packages = {
  ["neogit"] = {
    "TimUntersberger/neogit",
    -- commit = "981207efd10425fef82ca09fa8bd22c3ac3e622d",
    cmd = "Neogit",
    lazy = true,
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
          {
            "c",
            name = "+commits",
            {
              { "c", "<cmd>Neogit commit<CR>", name = "neogit commit" },
            },
          },
          { "N", "<cmd>Neogit<CR>", name = "Open Neogit" },
        },
      },
    },
  },
}

return neogit
