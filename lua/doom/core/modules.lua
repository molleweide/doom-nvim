--   doom.core.modules
--
--   Finds and returns user's `modules.lua` file.  Returned result is cached
--   due to lua's `require` caching.
--
--   Later on it executes all of the enabled modules, loading their packer dependencies, autocmds and cmds.

local log = require("doom.utils.logging")
local profiler = require("doom.services.profiler")
local utils = require("doom.utils")
local filename = "modules.lua"

local modules = {}

-- Path cases:
--   1. stdpath('config')/../doom-nvim/modules.lua
--   2. stdpath('config')/modules.lua
--   3. <runtimepath>/doom-nvim/modules.lua
modules.source = utils.find_config(filename)

-- Merge core modules (can't be disabled) with user enabled modules
local core_modules = {
    core = {
        { "doom",       enabled = true },
        { "nest",       enabled = true },
        { "treesitter", enabled = true },
        { "reloader",   enabled = true },
        { "updater",    enabled = true },
    },
}

-- TODO: Rename to get [module declarations] or [module tree]??
local function load_enabled_modules()
    local ok, result = xpcall(dofile, debug.traceback, modules.source)
    if ok then
        result = vim.tbl_deep_extend("keep", core_modules, result)
    end
    return ok, result
end
modules.enabled_modules = load_enabled_modules -- vim.tbl_deep_extend("keep", core_modules, dofile(modules.source))

local keymaps_service = require("doom.services.keymaps")
local commands_service = require("doom.services.commands")
local autocmds_service = require("doom.services.autocommands")

--- Iterate doom.modules and call [load_module] on each.
modules.load_modules = function()
    require("doom.utils.modules").traverse_loaded(doom.modules, function(node, stack)
        if node.type then
            local t_path = vim.tbl_map(function(stack_node)
                return type(stack_node.key) == "string" and stack_node.key
            end, stack)
            local path_module = table.concat(t_path, ".")
            modules.load_module(node, path_module)
        end
    end, { name = "[core/modules]: load modules", debug = false })
end

--- Applies commands, autocommands, packages for a single module
---@param module table Doom module table
---@param path_module string The lua module path inside the doom.modules dir, eg. "features.telescope"
modules.load_module = function(module, path_module)
    local profile_msg = ("modules|init `%s`"):format(path_module)
    profiler.start(profile_msg)

    -- print(path_module)

    -- Flag to continue enabling module
    local should_enable_module = true

    -- Check module has necessary dependencies
    if module.requires_modules then
        for _, dependent_module in ipairs(module.requires_modules) do
            if not utils.get_set_table_path(doom.modules, vim.split(dependent_module, "%.")) then
                should_enable_module = false
                log.error(
                    ('Doom module "%s" depends on a module that is not enabled "%s".  Please enable the %s module.')
                    :format(
                        path_module,
                        dependent_module,
                        dependent_module
                    )
                )
            end
        end
    end

    if should_enable_module then
        -- Import dependencies with packer from module.packages
        if module.packages then
            for dependency_name, packer_spec in pairs(module.packages) do
                -- Set packer_spec to configure function
                if module.configs and module.configs[dependency_name] then
                    packer_spec.config = module.configs[dependency_name]
                end

                local spec = vim.deepcopy(packer_spec)

                -- Set/unset frozen packer dependencies
                if type(spec.commit) == "table" then
                    -- Commit can be a table of values, where the keys indicate
                    -- which neovim version is required.
                    spec.commit = utils.pick_compatible_field(spec.commit)
                end

                -- Only pin dependencies if doom.freeze_dependencies is true
                spec.pin = spec.commit and doom.settings.freeze_dependencies

                -- Save module spec to be initialised later
                table.insert(doom.packages, spec)
            end
        end

        -- TODO: pass the whole spec to the service

        -- Setup package autogroups
        if module.autocmds then
            local autocmds = type(module.autocmds) == "function" and module.autocmds()
                or module.autocmds
            for _, autocmd_spec in ipairs(autocmds) do
                autocmds_service.set(
                    autocmd_spec[1],
                    autocmd_spec[2],
                    autocmd_spec[3],
                    autocmd_spec,
                    path_module
                )
            end
        end

        if module.cmds then
            for _, cmd_spec in ipairs(module.cmds) do
                commands_service.set(cmd_spec[1], cmd_spec[2], cmd_spec[3] or cmd_spec.opts)
            end
        end

        if module.binds then
            keymaps_service.applyKeymaps(
                type(module.binds) == "function" and module.binds() or module.binds
            )
        end

        -- use keys here to ensure that callbacks persist across reloades.
        if module.on_loaded_each then
            doom._on_loaded_callbacks.each[path_module] = module.on_loaded_each
        end

        -- on single only should depend on the module itself and therefore we can
        -- just reset the list, loop and call.
        if module.on_loaded_single then
            table.insert(doom._on_loaded_callbacks.single, module.on_loaded_single)
        end
    end
    profiler.stop(profile_msg)
end

-- Remove all configs for all modules.
modules.unload_modules = function()
    commands_service.del_all()
    autocmds_service.del_all()
    require("doom.utils.modules").traverse_loaded(doom.modules, function(node, stack)
        if node.type then
            local t_path = vim.tbl_map(function(stack_node)
                return type(stack_node.key) == "string" and stack_node.key
            end, stack)
            local path_module = table.concat(t_path, ".")
            modules.unload_module(node, path_module, true)
        end
    end, { name = "[core/modules]: unload modules", debug = false })
end

--- Remove all configs pertaining to a specific module.
modules.unload_module = function(module, path_module, ignore)
    local profile_msg = ("modules|unload `%s`"):format(path_module)
    profiler.start(profile_msg)

    if not ignore then
        if module.cmds then
            for _, cmd_spec in
            ipairs(type(module.cmds) == "function" and module.cmds() or module.cmds)
            do
                commands_service.del(cmd_spec[1])
            end
        end
        if module.autocmds then
            for _, autocmd_spec in
            ipairs(type(module.autocmds) == "function" and module.autocmds() or module.autocmds)
            do
                if not autocmd_spec.once then
                    autocmds_service.del_by_signature(path_module, autocmd_spec[1], autocmd_spec[2])
                end
            end
        end
    end

    if module.binds then
        keymaps_service.applyKeymaps(
            type(module.binds) == "function" and module.binds() or module.binds,
            nil,
            "delete"
        )
    end

    profiler.stop(profile_msg)
end

--- Applies user's commands, autocommands, packages from `use_*` helper functions.
modules.handle_user_config = function()
    -- TODO: pass the whole spec to the service

    -- Handle extra user cmds
    for _, cmd_spec in pairs(doom.cmds) do
        commands_service.set(cmd_spec[1], cmd_spec[2], cmd_spec[3] or cmd_spec.opts)
    end

    -- Handle extra user autocmds
    for _, autocmd_spec in pairs(doom.autocmds) do
        autocmds_service.set(
            autocmd_spec[1],
            autocmd_spec[2],
            autocmd_spec[3],
            autocmd_spec,
            "config.lua"
        )
    end

    -- Handle extra user keybinds
    -- FIX: Shouldn't this be moved to the nest module??
    for _, keybinds in ipairs(doom.binds) do
        keymaps_service.applyKeymaps(keybinds)
    end

    log.debug("doom.modules -> loaded user configs (config.lua)")
end

modules.unload_user_config = function()
    for _, cmd_spec in pairs(doom.cmds) do
        commands_service.del(cmd_spec[1])
    end
    for _, autocmd_spec in pairs(doom.autocmds) do
        if not autocmd_spec.once then
            autocmds_service.del_by_signature(
                "config.lua", -- maybe make these user-autocmd logic into their own api funcs
                autocmd_spec[1],
                autocmd_spec[2]
            )
        end
    end
    for _, keybinds in ipairs(doom.binds) do
        keymaps_service.applyKeymaps(keybinds, nil, "delete")
    end
end

-- ---Creates a user autocmd
-- modules.try_sync = function()
--     if modules._needs_sync then
--         vim.api.nvim_create_autocmd("User", {
--             -- should we switch this to :LazyCheck?
--             pattern = "PackerComplete",
--             callback = function()
--                 local log = require("doom.utils.logging")
--                 log.error("Doom-nvim has been installed.  Please restart doom-nvim.")
--             end,
--         })
--     end
-- end

modules.handle_lazynvim = function()
    if doom.settings.using_ghq then
        -- print("handle_lazynvim -> using_ghq")
        for _, spec in ipairs(doom.packages) do
            if spec.dev then
                local plugin_name = spec[1]
                table.remove(spec, 1)
                spec.dev = nil
                spec["dir"] = doom.settings.local_plugins_path .. "/" .. plugin_name
            end
            if spec.dependencies then
                for _, spec in pairs(spec.dependencies) do
                    if type(spec) == "table" then
                        if spec.dev then
                            local plugin_name = spec[1]
                            table.remove(spec, 1)
                            spec.dev = nil
                            spec["dir"] = doom.settings.local_plugins_path .. "/" .. plugin_name
                        end
                    end
                end
            end
        end
    end
    require("lazy").setup(doom.packages, {
        dev = {
            path = doom.settings.local_plugins_path,
        },
    })
end

modules.on_loaded_callbacks = function()
    for i, fn in ipairs(doom._on_loaded_callbacks.single) do
        if type(fn) == "function" then
            fn()
            log.debug(string.format("on_loaded_single #%s was run", i))
        end
    end
    for key, fn in pairs(doom._on_loaded_callbacks.each) do
        if type(fn) == "function" then
            fn()
            log.debug(string.format("on_loaded_each for [%s] was run.", key))
        end
    end
end

return modules
