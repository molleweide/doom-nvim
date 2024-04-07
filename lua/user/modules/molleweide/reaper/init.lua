local rk_definitions = "~/reaper/packages/reaper-keys/definitions/"

local rk = {}

-- OLD NOTES/RESOURCES
-- -- https://github.com/NlGHT/Night-REAPER-Scripts/blob/master/Scripting%20Tools/GetReaScriptAPI
-- -- https://github.com/NlGHT/Night-REAPER-Scripts/blob/master/Scripting%20Tools/MakeEELSnippets
-- -- https://github.com/NlGHT/vim-eel

-- NOTE:

-- TODO: ~ Inspect binding trees with treesitter
--       ~ Add chord UI.
--       ~ Add whatever notes/todos/ideas from reaper into neovim.
--       ~ Show symbol clashes in real time, so that leader keys can be
--         build/kept in mult files. IE. take inspiration from doom.
--       ~

-- FIX: xx

-- rk.cmds = {}

-- rk.autocmds = {}

local REAPER_DIR = "$HOME/reaper"
local REAPER_APP_DIR = "$REAPER_DIR/app"
local REAPER_PACKAGES_DIR = "$REAPER_DIR/packages"
local REAPER_PROJECTS_DIR = "$REAPER_DIR/projects"
local REAPER_TMP_DIR = "$REAPER_DIR/tmp"
local REAPER_BACKUP_DIR = "$REAPER_DIR/backup"
local REAPER_SAMPLES_DIR = "$REAPER_DIR/samples"

-- FIX: move all scripts to GHQ - find repos and clone..
local REAPER_APP_SCRIPTS_DIR = REAPER_APP_DIR .. "/reaper/Scripts"

local RK_DIR = "$REAPER_DIR/packages/reaper-keys"

local RK_DEFINITIONS = RK_DIR .. "/definitions"
local RK_INTERNALS = RK_DIR .. "/internals"

local RK_DEF_DEFAULTS_DIR = "/defaults"

local function inspect_rk_bindings_tree() end

local function inspect_rk_actions_table() end

local function apply_rk_internals_analysis() end

local centered_promp_for_reaper_script_dit = {
  cwd = REAPER_APP_SCRIPTS_DIR,
  layout_strategy = "center",
  layout_config = {
    anchor = "S",
    -- mirror = true,
    -- prompt_position = "bottom",
    height = 0.6,
    width = 0.6,
    preview_cutoff = 30,
  },
}

rk.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "R",
        name = "+reaper",
        {
          {
            "A",
            name = "Edit default actions",
            "<cmd>e " .. rk_definitions .. "defaults/actions.lua" .. "<CR>",
          },
          {
            "R",
            name = "find reaper definitions",
            function()
              require("telescope.builtin").find_files({
                cwd = rk_definitions,
              })
            end,
          },
          {
            "A",
            name = "find reaper scripts",
            function()
              require("telescope.builtin").find_files(centered_promp_for_reaper_script_dit)
            end,
          },
          {
            "Q",
            name = "grep reaper scripts",
            function()
              require("telescope.builtin").live_grep(centered_promp_for_reaper_script_dit)
            end,
          },

          {
            "u",
            name = "+user",
            {
              {
                "a",
                name = "edit user actions",
                "<cmd>e " .. rk_definitions .. "actions.lua" .. "<CR>",
              },
              {
                "b",
                name = "edit user bindings",
                "<cmd>e " .. rk_definitions .. "bindings.lua" .. "<CR>",
              },

              {
                "c",
                name = "edit user config",
                "<cmd>e " .. rk_definitions .. "config.lua" .. "<CR>",
              },
            },
          },
        },
      },
    },
  },
}

return rk
