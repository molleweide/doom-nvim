local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")

local pu = require("doom.modules.features.dui.templates")

local M = {}

local QUERY = [[
    (return_statement (expression_list (table_constructor) @table_constructor))
]]

local mod_manager_header = [[

------------------------------------
|-- MANAGE_MODULES: #ACTIONS: %s --|
------------------------------------

]]

local function build_new_inject_string(tree)
    local ret = vim.split(vim.inspect(tree), "\n")
    print("BUILD NEW INJECT STRING2", #ret, vim.inspect(ret))
    if #ret > 2 then
        -- trim surrounding braces {...}
        -- table.remove(ret, 1)
        -- table.remove(ret)
        ret[1] = string.sub(ret[1], 2)
        ret[#ret] = string.sub(ret[#ret], 1, -2)
        -- else
        --     ret = { string.sub(ret[1], 2, -2) }
    end
    return ret
end

-- TODO: ts_tbl_path needs to be extracted in its generalized form so that
-- one can use it on any table, eg add_branch_table_under_cursor
--
--- TS get set table path
---@param Takes TS object we are working on.
---@param Table of path components to check for
function ts_tbl_path(ts_table_constr, target)
    target.t_path_left = vim.deepcopy(target.t_path)
    local depth = 0
    ---@param table_constructor_wrapper TS node wrapper of table constructor
    local function ts_root_mod_tbl_try_find_target(branch_table)
        depth = depth + 1
        target.parent_table_node = branch_table

        if #target.t_path_left > 1 then
            local lookup_key = target.t_path_left[1]:upper()
            local is_branch, ts_tbl_child
            if branch_table:dict(lookup_key) then
                is_branch = true
                ts_tbl_child = branch_table:dict(lookup_key).value
                table.remove(target.t_path_left, 1)
            end

            return not is_branch and target or ts_root_mod_tbl_try_find_target(ts_tbl_child)
        elseif #target.t_path_left == 1 then -- handle indexed fields | for each table
            for _, leaf_table, field in branch_table:iter_fields("indexed") do
                if
                    leaf_table:dict(1)
                    and tostring(leaf_table:dict(1).value:content()) == target.t_path_left[1]
                then
                    target.module_found_node = leaf_table
                end
                if target.module_found_node and leaf_table:dict("enabled") then
                    target.module_field_enabled_value_node = leaf_table:dict("enabled").value
                    table.remove(target.t_path_left, 1)
                    return target
                end
            end
        end
        return target
    end
    return ts_root_mod_tbl_try_find_target(ts_table_constr)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(ts_buf, action)
    if not ts_buf or not action.action then
        log.debug("Cannot pass <nil> as an argument!")
        return
    end

    -- print(": enter transformer :", vim.inspect(action))

    vim.iter(ipairs(action))
        :map(function(_, target)
            return ts_tbl_path(ts_buf:query_wrap(QUERY)[1], target)
        end)
        :totable()

    table.sort(action, function(a, b)
        return a.module_found_node and a.module_found_node:range()
            or a.parent_table_node:range() < b.module_found_node and b.module_found_node:range()
            or b.parent_table_node:range()
    end)

    -- print("action table post [ts_root_mod_tbl_try_find_target]:", vim.inspect(action))

    local injection_nodes = {}

    -- vim.iter(ipairs(action)):rev():each(function() end)
    for i = #action, 1, -1 do
        local target = action[i]

        if action.action == "TOGGLE" then
            -- print("DO TOGGLE:", tn.module_found_node)
            target.module_field_enabled_value_node:toggle()
        end
        if action.action == "ENABLE" then
            target.module_field_enabled_value_node:set(true)
        end
        if action.action == "DISABLE" then
            target.module_field_enabled_value_node:set(false)
        end
        if action.action == "REMOVE" then
            target.module_found_node:remove({ up_to = "first_sibling" })
        end

        if action.action == "ADD" then
            local id = target.parent_table_node:id()
            local t_injectable
            for i, v in ipairs(injection_nodes) do
                if v.node:id() == id then
                    t_injectable = v
                end
            end
            if not t_injectable then
                t_injectable = {
                    parent_table_node = target.parent_table_node,
                    injection_table = {},
                }

                table.insert(injection_nodes, t_injectable)
            end
            setmetatable(t_injectable, {
                __index = target.parent_table_node, -- fallback/ makes TSNode methods available directly
            })

            local t_path_new_segment = vim.deepcopy(target.t_path_left)
            table.remove(t_path_new_segment) -- remove last item, ie. the module name

            t_path_new_segment = vim.iter(t_path_new_segment)
                :map(function(v)
                    return v:upper()
                end)
                :totable()

            local new_name, new_branch
            if #t_path_new_segment > 0 then
                new_name = target.t_path_left[#target.t_path_left]
                new_branch =
                    utils.get_set_table_path(t_injectable.injection_table, t_path_new_segment)
                if not new_branch then
                    new_branch = {}
                    utils.get_set_table_path(
                        t_injectable.injection_table,
                        t_path_new_segment,
                        new_branch
                    )
                end
            else
                new_name = target.t_path[#target.t_path]
                new_branch = t_injectable.injection_table
            end

            table.insert(new_branch, { new_name, enabled = true })
        end
    end

    -- inject new data
    if #injection_nodes > 0 then
        table.sort(injection_nodes, function(a, b)
            return a:range() > b:range()
        end)
        for _, injectable in ipairs(injection_nodes) do
            injectable:add_field({
                pos = "first",
                data = build_new_inject_string(injectable.injection_table),
            })
        end
    end

    return true
end

-- TODO: ( ) Later, I have to add proper error handling for everything.
-- TODO: ( ) Prevent creating/copying/moving to already existing locations.
--              ^ Is already kind of th case but it should be properly handled.
--              ^ Prevent path/branch name collisions.
-- TODO: ( ) Use switch pattern: put all actions in a table.
-- TODO: ( ) If action is NOT modspec, then call it with ModSpec.
--              ^ How to check if is modspec? >> add a __name = "ModSpec"
-- TODO: ( ) Call [core/modules.load/unload()] module when necessary.
-- TODO: ( ) Search-and-Replace module path and doom table identifier path
--              upon copy, and moving.
-- TODO: ( ) If [remove] check what downstream modules that are affected.
--              Ie. which modules are trying to access the removed module.
--              ^ Inform user!!! prompt: should we unload affected modules??
--
---Entry point for performing modules related operations, eg. CRUD. It
---ensures that the modules.lua file and the modules directory stay in
---sync and allows you to easilly manage modules from eg. telescope.
M.manage_modules_tree = function(action)
    local debug = true
    local should_apply_formatting = true
    local Path = require("pathlib")

    print(
        string.format(
            mod_manager_header,
            tostring(#action):len() == 1 and " " .. tostring(#action) or #action
        )
    )
    print(string.format("ACTION: <<%s>>", vim.inspect(action))) --, vim.inspect(action))

    local function map_ts_action(which, action_name)
        local ts_action = { action = action_name }
        for i, v in ipairs(action) do
            -- TODO: have a smart print statement that only prints if true, and move to some util.. logging?
            _ = debug
                and print(
                    string.format(
                        "-----%s-----\nold: %s \nnew: %s",
                        action_name,
                        v.old:path(),
                        v.new and v.new:path()
                    )
                )
            table.insert(ts_action, v[which])
            return ts_action
        end
    end

    local buf = utils.get_buf_handle(utils.find_config("modules.lua"))

    local ts_buf = require("doom.utils.ts.lua"):new(buf)
    if action.action == "ADD" then
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("new", "ADD"))

        -- NOTE: the issue is that i return the full path and not the path object which is
        -- what we want.

        for i, v in ipairs(action) do
            -- add/create new module file.
            local path_new = Path(v.new:path())
            local ok = path_new:touch(Path.permission("rw-r--r--"), true)

            if not ok then
                log.info("failure creating file:", path_new)
                return
            end

            -- write_file is async IIRC so it does not return bool
            fs.write_file(path_new:tostring(), pu.gen_temp_from_mod_name(v.new[1]), "w+")

            -- if not ok then
            --     log.info("failure writing module template to:", path_new)
            --     return
            -- end

            -- utils.edit_file_in_window(v.new:path(), "current")
        end
    elseif action.action == "REMOVE" then
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("old", "REMOVE"))
        for i, v in ipairs(action) do
            fs.rm_dir(v.old:dir())
        end
    elseif action.action == "MOVE" then
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("old", "REMOVE"))
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("new", "ADD"))
        for i, v in ipairs(action) do
            -- obj = { code = 0, signal = 0, stdout = 'hello', stderr = '' }
            local obj = vim.system({ "mv", v.old:dir(), v.new:dir() }):wait()
        end
    elseif action.action == "COPY" then
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("new", "ADD"))
        for i, v in ipairs(action) do
            local obj = vim.system({ "cp", "-R", v.old:dir(), v.new:dir() }):wait()
        end
    elseif vim.tbl_contains({ "TOGGLE", "ENABLE", "DISABLE" }, action.action) then
        local ok = transform_enabled_modules_tree(ts_buf, map_ts_action("old", action.action))
    end

    if should_apply_formatting then
        vim.api.nvim_buf_call(buf, function()
            vim.lsp.buf.format({ async = true })
            vim.cmd("write")
            log.info("DUI: TS transform modules.lua -> lsp.buf.formatted()")
        end)
    end
end

return M
