-- Store state that persists between reloads here.
_G._doom_reloader = _G._doom_reloader ~= nil and _G._doom_reloader or {}

-- NOTE: lazy reload plugin should be possible now:
-- https://github.com/folke/lazy.nvim/issues/445

-- BUG: reload in Dashboard -> line numbers become visible

-- TODO: Prevent reloading if there are LSP errors in the current buffer.

-- TODO: move to config globals so that it is easier to reuse and debug
--    packages

-- TODO: PackerCompile
--
--      how do I check if a config is dirty
--
--      if _doom.has_dirty_configs then
--        :PackerCompile
--      end

-- TODO: PackerSync -> PackerCompile
--
--
--  get list of packages pre/post reload.
--      if #pre ~= #post -> run PackerSync.
--
--      on PackerSync.complete -> run PackerCompile
--
--

local function test_print_package_pattern(k, pat)
  if string.match(k, pat) then
    print("has pat '" .. pat .. "'", k)
  end
end

local reloader = {}

--- Only show error reloading message once per session
reloader.has_failed_reload = false

local utils = require("doom.utils")
local log = require("doom.utils.logging")
local system = require("doom.core.system")

-- Should cause error if plenary is not installed.
xpcall(require, debug.traceback, "plenary")

--- Converts a Lua module path into an acceptable Lua module format
--- @param module_path string The path to the module
--- @return string|nil
local function path_to_lua_module(module_path)
  local lua_path = string.format("%s%slua", system.doom_root, system.sep)

  -- Remove the Neovim config dir and the file extension from the path
  module_path = string.match(
    module_path,
    string.format("%s%s(.*)%%.lua", utils.escape_str(lua_path), system.sep)
  )

  if not module_path then
    return nil
  end

  -- Replace '/' with '.' to follow the common Lua modules format
  module_path = module_path:gsub(system.sep, ".")

  -- Remove '.init' if the module ends with it
  module_path = module_path:gsub("%.init$", "")

  return module_path
end

--- Reloads all Neovim runtime files found in plugins
--- Reload a Lua module
--- @param mod_path string The configuration module path
--- @param quiet boolean If the reloader should send an info log or not
reloader.reload_lua_module = function(mod_path, quiet)
  if mod_path:find("/") then
    mod_path = path_to_lua_module(mod_path)
  end

  -- If doom-nvim fails to reload, warn user once per session
  if mod_path == nil then
    if reloader.has_failed_reload == false then
      log.warn(
        "reloader: Failed to reload doom config because this file is not in nvim config directory.  Is your doom nvim config directory symlinked?"
      )
      reloader.has_failed_reload = true
    end
    return
  end

  -- Get the module from package table
  local mod = package.loaded[mod_path]

  -- Unload the module and load it again
  package.loaded[mod_path] = nil
  require(mod_path)

  if type(mod) == "function" then
    -- Call the loaded module function so the reloading will take effect as expected
    local ok, _ = xpcall(package.loaded[mod_path], debug.traceback)
    if not ok then
      log.error(string.format("Failed to reload '%s' module", mod_path))
    end
  end

  if not quiet then
    log.info(string.format("Successfully reloaded '%s' module", mod_path))
  end
end

--- Reload all Neovim configurations
reloader._reload_doom = function()
  vim.cmd("hi clear")

  if vim.fn.exists(":LspRestart") ~= 0 then
    vim.cmd("silent! LspRestart")
  end

  -- NOTE: Comparing `enabled_modules` only works if there is a new module,
  -- but internals of a module will fall through.

  -- TODO: more finegrained collection of doom.modules packages so that we
  -- can auto determine whether or not to run PackerSync and PackerCompile.

  -- Remember which modules/packages installed to check if user needs to `:PackerSync`
  local ok, old_modules = require("doom.core.modules").enabled_modules()

  if not ok then
    log.warn("?? Reloader: could not load enabled modules! Aborting...:", type(old_modules))
    return
  end

  local old_packages = vim.tbl_map(function(t)
    return t[1]
  end, doom.packages)

  -- Reset State
  require("doom.services.commands").del_all()
  require("doom.services.autocommands").del_all()
  require("doom.services.profiler").reset()

  -- Unload doom.modules/doom.core lua files
  for k, _ in pairs(package.loaded) do
    if
      -- this is just so you can toggle/test more easilly
      string.match(k, "^doom%.core")
      or string.match(k, "^doom%.modules")
      or string.match(k, "^doom%.utils")
      or string.match(k, "^user%.modules")
      or string.match(k, "^user%.utils")
    then
      package.loaded[k] = nil
      -- print("unload path: ", k)
    end
  end

  -- Reload core entry point
  reloader.reload_lua_module("doom.core", true)
  -- Reload which modules are enabled
  reloader.reload_lua_module("doom.core.modules", true)
  -- Prepare the enabled modules, reload the user config.lua
  reloader.reload_lua_module("doom.core.config", true)
  require("doom.core.config"):load()

  -- Install, bind, add autocmds etc for all modules and user configs
  require("doom.core.modules"):load_modules()
  require("doom.core.modules"):handle_user_config()

  -- Post reload modules comparison
  local ok, modules = require("doom.core.modules").enabled_modules()
  local packages = vim.tbl_map(function(t)
    return t[1]
  end, doom.packages)
  local needs_install = vim.deep_equal(modules, old_modules)
    and vim.deep_equal(packages, old_packages)
  if needs_install then
    if not _G._doom_reloader._has_shown_packer_compile_message then
      log.warn(
        "reloader: You will have to run `:Lazy build` before changes to plugin configs take effect."
      )
      _G._doom_reloader._has_shown_packer_compile_message = true
    end
  else
    log.warn("reloader: Run `:Lazy sync` to install and configure new plugins.")
  end

  -- VimEnter to emulate loading neovim
  vim.cmd("doautocmd VimEnter")
  -- vim.cmd("doautocmd BufEnter")
  vim.cmd("doautocmd ColorScheme")
  vim.cmd("doautocmd Syntax")
end

-- FIX: This function should not be responsible for check if `reload_on_save`,
-- rather that should be done in a preceding stage.
--- Reload Neovim and simulate a new run
reloader.reload = function()
    local ok = require("doom.core.modules").enabled_modules()

    if not ok then
      log.warn("Enabled modules file could not be loaded. Fix this before we can reload...")
      return
    end

    -- Store the time taken to reload Doom
    local reload_time = vim.fn.reltime()
    log.info("Reloading Doom ...")

    --- Reload Neovim configurations
    reloader._reload_doom()

    log.info(
      "Reloaded Doom in "
        .. vim.fn.printf("%.3f", vim.fn.reltimefloat(vim.fn.reltime(reload_time)))
        .. " seconds"
    )
end

reloader.reload_if_on_save_enabled = function()
  if doom.modules.core.reloader.settings.reload_on_save then
    reloader.reload()
  else
    log.info("[Reloader]: Reload disabled...")
  end
end

reloader.settings = {
  reload_on_save = false,
  packer_sync_and_compile = true,
  autocmd_patterns = {

    -- 							*file-pattern*
    -- The pattern is interpreted like mostly used in file names:
    -- 	*	matches any sequence of characters; Unusual: includes path
    -- 		separators
    -- 	?	matches any single character
    -- 	\?	matches a '?'
    -- 	.	matches a '.'
    -- 	~	matches a '~'
    -- 	,	separates patterns
    -- 	\,	matches a ','
    -- 	{ }	like \( \) in a |pattern|
    -- 	,	inside { }: like \| in a |pattern|
    -- 	\}	literal }
    -- 	\{	literal {
    -- 	\\\{n,m\}  like \{n,m} in a |pattern|
    -- 	\	special meaning like in a |pattern|
    -- 	[ch]	matches 'c' or 'h'
    -- 	[^ch]   match any character but 'c' and 'h'

    basic = "*/doom/**/*.lua,*/user/**/*.lua",
    detailed = {
      -- doom
      "*/lua/doom/core/**/*.lua",
      "*/lua/doom/modules/**/*.lua",
      "*/lua/doom/services/**/*.lua",
      "*/lua/doom/tools/**/*.lua",
      "*/lua/doom/utils/**/*.lua",
      -- user
      "*lua/user/modules/**/*.lua",
      "*lua/user/utils/**/*.lua",
    },
  },
}

reloader.packages = {}
reloader.configs = {}

reloader.cmds = {
  {
    "DoomReload",
    function()
      reloader.reload()
    end,
  },
}

reloader.autocmds = function()
  local autocmds = {}

  local concat_pattern = function(t_patterns)
    if type(t_patterns) == "table" then
      return table.concat(t_patterns, ", ")
    else
      return t_patterns
    end
  end

  local watch_patterns = concat_pattern(doom.modules.core.reloader.settings.autocmd_patterns.basic)

  -- TODO: settigs.disable_reload_for_patterns
  --      https://stackoverflow.com/questions/6496778/vim-run-autocmd-on-all-filetypes-except

  -- TODO: add tweak -> toggle reload

  -- RELOAD DOOM ON SAVE
  if doom.modules.core.reloader.settings.reload_on_save then
    table.insert(autocmds, { "BufWritePost", watch_patterns, reloader.reload_if_on_save_enabled })
    table.insert(autocmds, {
      "BufWritePost",
      "*/modules.lua,*/config.lua,*/settings.lua",
      function()
        if
          vim.fn.getcwd() == vim.fn.stdpath("config")
          or system.doom_configs_root == vim.fn.stdpath("config")
        then
          reloader.reload_if_on_save_enabled()()
        end
      end,
    })
  end

  return autocmds
end

reloader.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "D",
        name = "+doom",
        {
          {
            "L",
            function()
              doom.modules.core.reloader.settings.reload_on_save =
                not doom.modules.core.reloader.settings.reload_on_save
              print(
                "toggle doom reload on save: ",
                doom.modules.core.reloader.settings.reload_on_save
              )
            end,
            name = "ToggleReloadOnSave",
          },
        },
      },
    },
  },
}

return reloader
