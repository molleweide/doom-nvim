--[[
--  doom.core
--
--  Entrypoint for the doom-nvim framework.
--
--]]

local ensure_vim_dirs = function()
  local cache_dir = vim.env.HOME .. "/.cache/nvim/"
  local data_dir = {
    cache_dir .. "backup",
    cache_dir .. "session",
    cache_dir .. "swap",
    cache_dir .. "tags",
    cache_dir .. "undo",
  }
  -- There only check once that If cache_dir exists
  -- Then I don't want to check subs dir exists
  if vim.fn.isdirectory(cache_dir) == 0 then
    os.execute("mkdir -p " .. cache_dir)
    for _, v in pairs(data_dir) do
      if vim.fn.isdirectory(v) == 0 then
        os.execute("mkdir -p " .. v)
      end
    end
  end
end

local map_file_types = function()
    if not vim.filetype then
        return
    end
    vim.filetype.add({
        extension = {
            lock = "yaml",
        },
        filename = {
            ["NEOGIT_COMMIT_EDITMSG"] = "NeogitCommitMessage",
            [".psqlrc"] = "conf", -- TODO: find a better filetype
            ["go.mod"] = "gomod",
            [".gitignore"] = "conf",
            ["launch.json"] = "jsonc",
            Podfile = "ruby",
            Brewfile = "ruby",
        },
        pattern = {
            [".*%.conf"] = "conf",
            [".*%.theme"] = "conf",
            [".*%.gradle"] = "groovy",
            [".*%.env%..*"] = "env",
        },
    })
end

local mappings_reset = function()
    vim.g.mapleader = " "
    vim.g.maplocalleader = ","
    vim.keymap.set("n", "<SPACE>", "<Nop>", { noremap = true })
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })
    vim.keymap.set("n", "<esc>", function()
        require("notify").dismiss()
        vim.cmd.nohl()
    end, {})
end

--
-- Disable vim builtins for faster startup time
--

local g = vim.g

g.loaded_gzip = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1

g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_2html_plugin = 1

g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1

local profiler = require("doom.services.profiler")

--
-- Sets the `doom` global object
--

profiler.start("framework|doom.core.doom_global")
require("doom.core.doom_global")
profiler.stop("framework|doom.core.doom_global")

-- TODO: move these three into core/config.lua
-- ensure_vim_dirs()
-- map_file_types()
-- mappings_reset()
--

profiler.start("framework|doom.utils")
local utils = require("doom.utils")
profiler.stop("framework|doom.utils")

--
-- Boostraps the doom-nvim framework, runs the user's `config.lua` file.
--

profiler.start("framework|doom.core.config (setup + user)")
local config = utils.safe_require("doom.core.config")
config.load()
profiler.stop("framework|doom.core.config (setup + user)")

--

if not utils.is_module_enabled("features", "netrw") then
  g.loaded_netrw = 1
  g.loaded_netrwPlugin = 1
  g.loaded_netrwSettings = 1
  g.loaded_netrwFileHandlers = 1
end

--
-- Set some extra commands
--

utils.safe_require("doom.core.commands")

profiler.start("framework|doom.core.modules")

--
-- Load Doom modules.
--

local modules = utils.safe_require("doom.core.modules")

profiler.start("framework|init enabled modules")
modules.load_modules()
profiler.stop("framework|init enabled modules")

profiler.start("framework|user settings")
modules.handle_user_config()
profiler.stop("framework|user settings")

modules.try_sync()

modules.handle_lazynvim()

profiler.stop("framework|doom.core.modules")

doom.core.nest.reload_binds()

--
-- Load the colourscheme
--

profiler.start("framework|doom.core.ui")
utils.safe_require("doom.core.ui")
profiler.stop("framework|doom.core.ui")

-- Execute autocommand for user to hook custom config into
vim.api.nvim_exec_autocmds("User", {
  pattern = "DoomStarted",
})

-- vim: fdm=marker
