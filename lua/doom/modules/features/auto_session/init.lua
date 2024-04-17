local auto_session = {}

auto_session.settings = {
  persisted = {
    save_dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/"), -- directory where session files are saved
    silent = false,                                                   -- silent nvim message when sourcing session file
    use_git_branch = false,                                           -- create session files based on the branch of a git enabled repository
    default_branch = "main",                                          -- the branch to load if a session file is not found for the current branch
    autosave = true,                                                  -- automatically save session files when exiting Neovim
    should_autosave = nil,                                            -- function to determine if a session should be autosaved
    autoload = false,                                                 -- automatically load the session for the cwd on Neovim startup
    on_autoload_no_session = nil,                                     -- function to run when `autoload = true` but there is no session to load
    follow_cwd = true,                                                -- change session file name to match current working directory if it changes
    allowed_dirs = nil,                                               -- table of dirs that the plugin will auto-save and auto-load from
    ignored_dirs = nil,                                               -- table of dirs that are ignored when auto-saving and auto-loading
    ignored_branches = nil,                                           -- table of branch patterns that are ignored for auto-saving and auto-loading
    telescope = {
      reset_prompt = true,                                            -- Reset the Telescope prompt after an action?
      mappings = {                                                    -- table of mappings for the Telescope extension
        change_branch = "<c-b>",
        copy_session = "<c-c>",
        delete_session = "<c-d>",
      },
    },
  },
}

-- https://github.com/rmagatti/auto-session
--
--
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-sessions.md
--
-- https://github.com/gennaro-tedesco/nvim-possession
--
-- https://github.com/olimorris/persisted.nvim
--
-- https://github.com/jedrzejboczar/possession.nvim
--
-- https://github.com/olimorris/persisted.nvim

auto_session.packages = {
  ["persisted.nvim"] = {
    "olimorris/persisted.nvim",
    lazy = false,
    -- commit = "8484fdaa284207f77ec69b9627316bf334ad653f",
  dev = true
  },
  --   -- https://github.com/Shatur/neovim-session-manager
  --   https://github.com/jedrzejboczar/possession.nvim
}

auto_session.configs = {}
auto_session.configs["persisted.nvim"] = function()
  require("persisted").setup(doom.features.auto_session.settings.persisted)

  require("telescope").load_extension("persisted")
end

-- Events / Callbacks
-- The plugin fires events at various points during its lifecycle:
--
-- PersistedLoadPre - For before a session is loaded
-- PersistedLoadPost - For after a session is loaded
-- PersistedTelescopeLoadPre - For before a session is loaded via Telescope
-- PersistedTelescopeLoadPost - For after a session is loaded via Telescope
-- PersistedSavePre - For before a session is saved
-- PersistedSavePost - For after a session is saved
-- PersistedDeletePre - For before a session is deleted
-- PersistedDeletePost - For after a session is deleted
-- PersistedStateChange - For when a session is started or stopped
-- PersistedToggled - For when a session is toggled

-- The plugin comes with a number of commands:
--
-- :SessionToggle - Determines whether to load, start or stop a session
-- :SessionStart - Start recording a session. Useful if autosave = false
-- :SessionStop - Stop recording a session
-- :SessionSave - Save the current session
-- :SessionLoad - Load the session for the current directory and current branch (if git_use_branch = true)
-- :SessionLoadLast - Load the most recent session
-- :SessionLoadFromFile - Load a session from a given path
-- :SessionDelete - Delete the current session

auto_session.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "q",
      name = "+quit",
      {
        {
          "s",
          [[<cmd>lua require("persisted").start()<cr>]],
          name = "Session start rec",
        },
        {
          "S",
          [[<cmd>lua require("persisted").stop()<cr>]],
          name = "Session stop rec",
        },
        {
          "r",
          [[<cmd>lua require("persisted").load()<cr>]],
          name = "Restore session -> cwd",
        },
        {
          "R",
          [[<cmd>lua require("persisted").load({ last = true})<cr>]],
          name = "Restore session -> last",
        },
        {
          "t",
          "<cmd>Telescope persisted<CR>",
          name = "Tele sessions",
        },
        {
          "T",
          [[<cmd>lua require("persisted").toggle()<cr>]],
          name = "Session toggle",
        },
        {
          "D",
          [[<cmd>lua require("persisted").delete()<cr>]],
          name = "Session delete",
        }
      },
    },
  },
}

return auto_session
