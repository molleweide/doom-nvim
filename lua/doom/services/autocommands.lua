--- AutoCommands Service,
--- Provides functions to wrap neovims APIs to set and remove autocmds
--- Acts as a compatibility layer between different API versions.
--- Manages references to all commands to be cleared for :DoomReload

-- TYPES

--- @class AutoCommandArgs
--- @field args string Args parsed to command (if any)
--- @field fargs string[] Args split by unescaped whitespace (if any)
--- @field line1 number Starting line of the command range
--- @field line2 number Final line of the command range
--- @field count number Any count supplied (if any)

--- @class SetAutoCommandOptions
--- @field descr string|nil
--- @field nested boolean|nil
--- @field once boolean|nil

-- TODO: We should just pass the autocmd_spec table to the api directly and then
-- handle all of the table indexing here, so that modules consuming this api look
-- a bit cleaner. >> Now it looks kinda ugly with all the table indexes.

--- IMPLEMENTATIONS
--- Wraps the nvim functionality to handle different neovim versions.
local utils = require("doom.utils")
local log = require("doom.utils.logging")

local DOOM_AUTOCMDS_NAMESPACE = "DoomAutoCommands"

-- Data to be stored globally so it can be accessed from the nvim-0.5 implementation
local data = _G._doom_autocmds_service_data
    or {
        -- Stores data relating to the auto command so they can be deleted on neovim < 0.8
        autocmd_signatures = {},
        -- Stores the lua function handlers for nvim version < 0.8
        autocmd_actions = {},
        -- Stores created autocommand ids from vim.api.nvim_create_autocmd (or custom shim in the v0.5 version)
        autocmd_ids = {},
        -- Map signature back to id
        autocmd_signatures_to_ids = {},
    }
_G._doom_autocmds_service_data = data

-- Store all autocommands inside of an augroup for doom-nvim
if vim.fn.has("nvim-0.8") then
    vim.api.nvim_create_augroup("DoomAutoCommands", { clear = true })
else
    vim.cmd([[
    augroup DoomAutoCommands
      autocmd!
    augroup END
  ]])
end

local function make_signature(path_module, event, pattern)
    return string.format(
        "%s %s %s",
        path_module,
        type(event) == "table" and table.concat(event, "|") or event,
        type(pattern) == "table" and table.concat(pattern, "|") or pattern
    )
end

-- WARN: If I make changes to how the opt table can be configured then,
-- v0.5 will have to be made compatible as well. However, now 0.5 is so
-- old and uncommon that it is not urgent..

-- create single

local set_autocmd_implementations = {
    ["nvim-0.5"] = function(event, pattern, action, opts)
        local cmd_string = "autocmd! "
        cmd_string = cmd_string .. ("%s %s "):format(event, pattern)

        local uid = utils.unique_index()
        data.autocmd_ids[uid] = true
        data.autocmd_signatures[uid] = cmd_string
        -- data.autocmd_signatures_to_ids[]

        if opts.nested then
            cmd_string = cmd_string .. "++nested "
        end
        if opts.once then
            cmd_string = cmd_string .. "++once "
        end

        if type(action) == "string" then
            cmd_string = cmd_string .. action .. " "
        else
            data.autocmd_actions[uid] = action

            cmd_string = cmd_string
                .. (":lua _doom_autocmds_service_data.autocmd_actions[%d]()"):format(uid)
        end
        vim.cmd(cmd_string)
        return uid
    end,
    ["latest"] = function(event, pattern, action, opts, path_module)
        local merged_opts = vim.tbl_extend("keep", opts, {
            pattern = pattern,
            group = DOOM_AUTOCMDS_NAMESPACE,
        })
        if type(action) == "function" then
            merged_opts.callback = action
        else
            merged_opts.command = action
        end

        -- remove indexed fields from the opts table
        if #merged_opts > 0 then
            for i = 1, 3 do
                table.remove(merged_opts)
            end
        end

        local id = vim.api.nvim_create_autocmd(event, merged_opts)
        local signature = make_signature(path_module, event, pattern)
        data.autocmd_ids[id] = true
        data.autocmd_signatures[id] = signature
        data.autocmd_signatures_to_ids[signature] = id
        -- print("create autocmd:", signature)
        return id
    end,
}
local set_autocmd_fn = utils.pick_compatible_field(set_autocmd_implementations)

-- delete single

local del_autocmd_implementations = {
    ["nvim-0.5"] = function(id)
        local delete_signature = data.autocmd_signatures[id]
        if delete_signature then
            vim.cmd(delete_signature)
        end
    end,
    ["latest"] = function(id)
        print("DELETE AUTOCMD ID:", id)
        vim.api.nvim_del_autocmd(id)
    end,
}
local del_autocmd_fn = utils.pick_compatible_field(del_autocmd_implementations)

-- delete all

local del_all_autocmd_implementations = {
    ["nvim-0.5"] = function()
        vim.cmd([[
      augroup DoomAutoCommands
        autocmd!
      augroup END
    ]])
    end,
    ["latest"] = function()
        vim.api.nvim_create_augroup("DoomAutoCommands", { clear = true })
        -- print("# X # X # X # X # X # X # X # X # X # X # X # X")
        data.autocmd_ids = {}
        data.autocmd_signatures = {}
        data.autocmd_actions = {}
    end,
}
local del_all_autocmd_fn = utils.pick_compatible_field(del_all_autocmd_implementations)

-- API
local autocmds_service = {}

autocmds_service.get_all = function()
    local all = vim.api.nvim_get_autocmds({})
    local all_doom_autocmds = {}
    for i, v in ipairs(all) do
        if v.group_name then
            -- print(v.group_name, doom_autocmds_namespace)
            if
                v.group_name == DOOM_AUTOCMDS_NAMESPACE
                or v.group_name == doom.features.monitoring.buffer_monitors_namespace
            then
                -- print(v.group_name, DOOM_AUTOCMDS_NAMESPACE, v.pattern)
                table.insert(all_doom_autocmds, v)
            end
        end
    end
    return all_doom_autocmds
end

-- TEST: If opts is a <string> then use it for desc instead of opts..

--- Set a neovim autocmd
---@param event string Name of autocmd
---@param pattern string Pattern to match autocommand with
---@param action string|function(AutoCommandArgs)
---@param opts SetAutoCommandOptions|nil
---@return number ID of autocommand, used to delete it later on
autocmds_service.set = function(event, pattern, action, opts, path_module)
    -- local resolved_opts = opts or {}
    opts = opts or {}

    -- NOTE: Why arent we just doing a tbl extend here?

    -- local stripped_opts = {
    --     nested = resolved_opts.nested or false,
    --     once = resolved_opts.once or false,
    --     desc = resolved_opts.descr or nil
    -- }
    return set_autocmd_fn(event, pattern, action, opts, path_module)
end

--- Deletes an autocommand from a given id
---@param id number ID of autocommand to delete
autocmds_service.del = function(id)
    del_autocmd_fn(id)
    data.autocmd_ids[id] = nil
    data.autocmd_signatures[id] = nil
    data.autocmd_actions[id] = nil
end

-- WARN: The signatures are not unique enough, there could be collisions.

--- Deletes an autocommand from it's signature string.
---@param id number ID of autocommand to delete
autocmds_service.del_by_signature = function(path_module, event, pattern)
    local sig_str = make_signature(path_module, event, pattern)
    local id = data.autocmd_signatures_to_ids[sig_str]
    log.trace(string.format([[
        signature: %s
        id: %s
        ]], sig_str, tostring(id)))
    autocmds_service.del(id)

    -- TODO: handle errors gracefully

    --         ok, result = xpcall(vim.keymap.del, debug.traceback, sanitizedMode, node.lhs)
    --         if ok then
    --             -- log.debug(string.format("Removed keymap [%s] for mode [%s]", node.lhs, sanitizedMode))
    --         else
    --             log.error(
    --                 string.format(
    --                     "Failure removing keymap [%s] for mode [%s]. Traceback:\n%s",
    --                     node.lhs,
    --                     sanitizedMode,
    --                     result
    --                 )
    --             )
    --         end
    --     end
    -- end
end

autocmds_service.del_all = function()
    del_all_autocmd_fn()
end

autocmds_service.namespace = DOOM_AUTOCMDS_NAMESPACE

return autocmds_service
