local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local utils = require("doom.utils")

local pu = require("doom.modules.features.dui.templates")
local dui_utils = require("doom.modules.features.dui.utils")

local M = {}

local QUERY = [[
    (return_statement (expression_list (table_constructor) @table_constructor))
]]

local function build_new_inject_string2(tree)
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

    vim.iter(ipairs(action))
        :map(function(_, target)
            return ts_tbl_path(ts_buf:query_wrap(QUERY), target)
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

        if action.action == "COPY" then
            -- TODO: inject new module path, and set it to [false] by default
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
                data = build_new_inject_string2(injectable.injection_table),
            })
        end
    end

    return true
end

-- NOTE: Use semaphore to ensure that only one module operation is run at once?
-- !! All core rocks nvim actions are ran with semaphore to ensure that
-- only one is ran at a time.
-- >>> Copy over the rocks operations helper file and

-- TODO: I have to prepare these async modules as if they were part of
-- Rocks nvim so that I do all of this properly.

local function module__create_dir_await(file_path, name)
    local Path = require("pathlib")
    log.info(("Adding new module: %s -> %s"):format(name, file_path:tostring()))
    local ok = file_path:touch(Path.permission("rw-r--r--"), true)
    if ok then
        ok = (fs.get_write_file_awaiter())(
            file_path:tostring(),
            "w",
            pu.gen_temp_from_mod_name(name)
        )
        if ok then
            return true
        end
    end
end

local function module__dir_move()
    log.info("Moving a module...")
end

local function module__dir_remove_async(dir_path)
    log.info("Removing a module:", dir_path)
    fs.rm_dir(dir_path)
end

local function module_load_single()
    -- model this after rocks load_dynamic
end

---@param file string The path to edit
---@param where string Eg. "current" for current window
local function open_file(file, where)
    vim.schedule(function()
        if where == "current" then
            print("nvim open current")
            -- vim.cmd(string.format("edit %s", file))
            --
            local buf = vim.uri_to_bufnr(vim.uri_from_fname(file))
            vim.api.nvim_set_current_buf(buf)
        elseif where == "split" then
        elseif where == "vsplit" then
        else
        end
    end)
end

---Entry point for performing modules related operations, eg. CRUD. It
---ensures that the modules.lua file and the modules directory stay in
---sync and allows you to easilly manage modules from eg. telescope.
---
---target_module_dir is assumed to be a Pathlib Path object.
--- NOTE: Should this be an async func that I use create to run with.
M.manage_modules_tree = function(opts)
    local should_apply_formatting = false
    local nio = require("nio")
    local Path = require("pathlib")
    local helpers = require("doom.modules.features.dui.operations.helpers.nio")
    if not nio or not Path then
        log.error(
            "Dui requires nio and pathlib for async. Enable modules [lib/pathlib] and [lib/nio]"
        )
        return
    end

    print(string.format(
        [[

------------------------------------
|-- MANAGE_MODULES: #ACTIONS: %s --|
------------------------------------

]],
        tostring(#opts):len() == 1 and " " .. tostring(#opts) or #opts
    ))

    local buf = dui_utils.get_buf_handle(utils.find_config("modules_test.lua"))
    local ts_buf = require("doom.utils.ts.lua"):new(buf)

    -- ts
    for i, action in ipairs(opts) do
        print(string.format("ACTION (%s/%s): <<%s>>", i, #opts, vim.inspect(action))) --, vim.inspect(action))
        local ok = transform_enabled_modules_tree(ts_buf, action)
        if not ok then
            log.warn(
                string.format(
                    "Failure updating [modules.lua] in action #%s:[%s]. Aborting..",
                    i,
                    action.action
                )
            )
            -- restore original state of file..
            return
        end
    end

    print("<POST TRANSFORM | PRE FORMATTING>")

    if should_apply_formatting then
        -- TEST: this actually makes sense to run as async
        vim.api.nvim_buf_call(buf, function()
            vim.lsp.buf.format({ async = false })
            vim.cmd("write")
            log.info("DUI: TS transform modules.lua -> lsp.buf.formatted()")
        end)
    end

    -- fs

    for i, action in ipairs(opts) do
        for _, target in ipairs(action) do
            -- FIX: the target path is wrong for the new module.

            print(string.format("#%s | FS %s: %s", i, action.action, target:dir()))

            -- NOTE: how should COPY be combined to get the desired results?
            -- ~ reuse ADD logic somehow
            -- ~ BUT if copy

            if opts.action == "ADD" and not path_init_file:exists() then
                -- local ok = target:path():touch(Path.permission("rw-r--r--"), true)
                --
                -- if not ok then
                --     log.info("failure creating file:", target:path())
                --     return
                -- end
                -- ok = fs.write_file(target:path(), pu.gen_temp_from_mod_name(name), "w+")
                --
                -- if not ok then
                --     log.info("failure writing module template to:", target:path())
                --     return
                -- end
                --
                -- if ok then
                --     open_file(target:path(), "current")
                -- end
            elseif opts.action == "COPY" then

                -- TODO:
                --  touch new file.
                --      write the previous file to it.
                --          (*) requires attaching the original path to the table, so that
                --              it can be used as source when copying to target:path()

                -- NOTE: currently each action[target] is a ModSpec table.
                --  but since i need the table for original and new. then it needs
                --  something likeg
                --  {
                --       current = ModSpec,
                --       new = ModSpec.
                --  }
                --  and then skip the iterating of all actions. instead loop
                --  targets only once. ie have only one action.
                --  and then

                -- Path:copy({target})                                                  *Path:copy*
                --     Copy file to `target`
                --
                --     Parameters: ~
                --         {target}  (PathlibPath)  # `self` will be copied to `target`
                --
                --     Returns: ~
                --         (boolean|nil)  # whether operation succeeded
            elseif opts.action == "REMOVE" then
                -- fs.rm_dir(target:dir())
                -- if ok then
                --     log.info("DUI: Success removing dir:", target:path())
                -- end
            end
        end
    end
end

return M
