-- Store state that persists between reloads here.
_G._doom_reloader = _G._doom_reloader ~= nil and _G._doom_reloader or { reload_on_save = false }

-- FIX: ( ) Need a way to reload if the reloader fails...

-- NOTE: lazy reload plugin should be possible now:
-- https://github.com/folke/lazy.nvim/issues/445

-- BUG: reload in Dashboard -> line numbers become visible

-- TODO: ( ) Prevent reloading if there are LSP errors in the current buffer.

local utils = require("doom.utils")
local log = require("doom.utils.logging")
local system = require("doom.core.system")

local reloader = {}

--- Only show error reloading message once per session
reloader.has_failed_reload = false

-- Should cause error if plenary is not installed.
xpcall(require, debug.traceback, "plenary")

local function bulk_unload_all_doom_modules()
    -- log.debug("unload all")
    for k, _ in pairs(package.loaded) do
        if
            -- this is just so you can toggle/test more easilly
            string.match(k, "^doom%.core")
            or string.match(k, "^doom%.modules")
            or string.match(k, "^doom%.services")
            or string.match(k, "^doom%.utils")
            or string.match(k, "^user%.modules")
            or string.match(k, "^user%.utils")
        then
            package.loaded[k] = nil
            -- print("unload path: ", k)
        end
    end
end

local function collect_old_state()
    local ok, old_modules = require("doom.core.modules").enabled_modules()
    if not ok then
        log.warn(
            string.format(
                "Could not load enabled modules! Type of `old_modules`:%s",
                type(old_modules)
            )
        )
        return
    end
    local old_packages = vim.tbl_map(function(t)
        return t[1]
    end, doom.packages)
    -- print(string.format("old packages\n%s", vim.inspect(old_packages)))
    return old_modules, old_packages
end

local function is_new_state_same_as_old(old_modules, old_packages)
    local ok, modules = require("doom.core.modules").enabled_modules()
    local packages = vim.tbl_map(function(t)
        return t[1]
    end, doom.packages)
    return vim.deep_equal(modules, old_modules) and vim.deep_equal(packages, old_packages)
end

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

--- Reload a single Lua module
--- @param mod_path string The configuration module path
--- @param quiet boolean If the reloader should send an info log or not
reloader.reload_lua_module = function(mod_path_pre, quiet)
    local mod_path
    if mod_path_pre:find("/") then
        mod_path = path_to_lua_module(mod_path_pre)
    else
        mod_path = mod_path_pre
    end

    -- print("mod_path:", mod_path)

    -- If doom-nvim fails to reload, warn user once per session
    if mod_path == nil then
        if reloader.has_failed_reload == false then
            log.warn(
                string.format(
                    "Failed to reload doom config because this file is not in nvim config directory. Is your doom nvim config directory symlinked? Failure happend for: %s",
                    mod_path_pre
                )
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

-------------------------------------------------------------------------------
-- We could optimize plugin and package comparisons, but currently, reloading,
-- a single module still only takes
--
-- NOTE: PACKAGES ---------------------------------------------------------
-- Currently, packages are all injected into the list [doom.packages]
-- TODO: also create a table [doom.packages_by_key] that maps each spec by
-- key so that we can quickly compare specs
--
-- NOTE: ENABLED MODULES --------------------------------------------------
-- Currently, with FULL reload, we require the full enabled modules list.
-- Would it even be faster to just obtain the modules we want to check by
-- get_set_table_path, and then compare them individually?
-------------------------------------------------------------------------------

--- Reload all Neovim configurations
reloader._reload_doom = function(opts)
    opts = opts or {}

    local reload_type = "FULL"
    local event_target_module

    log.warn("opts:", vim.inspect(opts))

    local args_table_str = vim.inspect(event)

    -- doom file type
    if opts.event then
        -- if opts.event.file:match("^%w-%.lua") then
        if opts.event.file:match("^%w-%.lua") then
            reload_type = "ROOT"
        elseif opts.event.file:match("doom/modules") or opts.event.file:match("user/modules") then
            reload_type = "SINGLE"
            event_target_module =
                opts.event.file:match("lua/(.+)%.lua$"):gsub("/", "."):gsub("%.init$", "")
        else
            reload_type = "CORE"
        end
        log.debug(
            string.format(
                "_doom_reloader.current_type = %s, event = %s",
                reload_type,
                args_table_str
            )
        )
    end

    if reload_type == "CORE" then
        reload_type = "FULL"
    end

    if reload_type == "FULL" then
        vim.cmd("hi clear")
        if vim.fn.exists(":LspRestart") ~= 0 then
            vim.cmd("silent! LspRestart")
        end
    end

    -- TODO: If subset, then only get old state from those modules.

    _doom_on_loaded_callbacks = {}

    -- reset the profiler
    require("doom.services.profiler").reset() -- ???????????

    -- TODO: Move cleanup back into [core.modules]

    local old_modules, old_packages = collect_old_state()
    if not old_modules then
        return
    end

    local keymaps_service = require("doom.services.keymaps")
    local commands_service = require("doom.services.commands")
    local autocmds_service = require("doom.services.autocommands")

    if reload_type == "ROOT" then
        require("doom.core.modules"):unload_user_config()
        -- reload
        require("doom.core.config").handle_post_import_modules()
        require("doom.core.modules"):handle_user_config()
        require("doom.core.modules"):handle_lazynvim()
    elseif reload_type == "SINGLE" then
        -- TEST: Collect meta data first, and attach to module??

        -- get table path from project path
        local t_path = vim.split(event_target_module, ".", true)
        table.remove(t_path, 1)
        table.remove(t_path, 1)
        local path_module = table.concat(t_path, ".")
        -- clean up module
        local old_module = utils.get_set_table_path(doom.modules, t_path)
        require("doom.core.modules").unload_module(old_module, path_module)
        -- reload (commands, autocmds, packages spec, and binds)
        reloader.reload_lua_module(event_target_module, false)
        local module = require("doom.core.config").attach_module(t_path)
        require("doom.core.modules").load_module(module, path_module)

        -- reloading lazy is not supported
        -- require("doom.core.modules"):handle_lazynvim()
        require("doom.core.modules").on_loaded_callbacks()

    elseif reload_type == "FULL" then
        require("doom.core.modules").unload_modules()
        bulk_unload_all_doom_modules()
        reloader.reload_lua_module("doom.core", false)
        -- reloading lazy is not supported
        -- require("doom.core.modules"):handle_lazynvim()
    else
        log.debug(string.format("Unknown reload type: %s", reload_type))
    end

    if is_new_state_same_as_old(old_modules, old_packages) then
        -- if not _G._doom_reloader._has_shown_packer_compile_message then
        log.warn(
            "RELOADER: You will have to run `:Lazy build` before changes to plugin configs take effect."
        )
        --     _G._doom_reloader._has_shown_packer_compile_message = true
        -- end
    else
        log.warn("RELOADER: Run `:Lazy sync` to install and configure new plugins.")
    end

    if reload_type == "FULL" then
        -- Lazy
        -- TODO: Only run lazy sync if there are packages that have been added or changed?
        -- vim.cmd("Lazy sync")

        -- VimEnter to emulate loading neovim
        vim.cmd("doautocmd VimEnter")
        -- vim.cmd("doautocmd BufEnter")
        vim.cmd("doautocmd ColorScheme")
        vim.cmd("doautocmd Syntax")
    end
end

--- Reload Neovim and simulate a new run
reloader.reload = function(opts)
    local ok = require("doom.core.modules").enabled_modules()
    if not ok then
        log.warn("Enabled modules file could not be loaded. Fix this before we can reload...")
        return
    end
    -- Store the time taken to reload Doom
    local reload_time = vim.fn.reltime()

    log.debug("pre reloading")

    --- Reload Neovim configurations
    reloader._reload_doom(opts)
    log.info(
        string.format(
            [[POST RELOAD: time elapsed = %s]],
            vim.fn.printf("%.3f", vim.fn.reltimefloat(vim.fn.reltime(reload_time))) .. " seconds"
        )
    )
end

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

function reloader.reload_doom_if_necessary(event)
    local is_config_dir = vim.fn.getcwd() == vim.fn.stdpath("config")
    if is_config_dir or system.doom_configs_root == vim.fn.stdpath("config") then
        -- log.debug(event.file)
        -- ignore reloading when manually changing the modules declaration file
        if event.file == "modules.lua" then
            return
        end
        if _doom_reloader.reload_on_save then
            reloader.reload({ event = event })
        end
    end
end

reloader.autocmds = {
    {
        "BufWritePost",
        "*.lua", -- i should make this pattern explicitly look at ~/.config/nvim/*.lua
        function(event)
            reloader.reload_doom_if_necessary(event)
        end,
        desc = "Reload doom config on changes.",
    },
}

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
                        name = "ToggleReloadOnSave",
                        function()
                            _doom_reloader.reload_on_save = not _doom_reloader.reload_on_save
                            vim.notify(
                                "Toggle reload_on_save -> "
                                    .. tostring(_doom_reloader.reload_on_save)
                            )
                            log.info(
                                string.format(
                                    "[reloader]: Toggle doom reload on save = %s",
                                    _doom_reloader.reload_on_save
                                )
                            )
                        end,
                    },
                },
            },
        },
    },
}

return reloader
