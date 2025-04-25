local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local utils = require("doom.utils")

local pu = require("doom.modules.features.dui.templates")
local dui_utils = require("doom.modules.features.dui.utils")

local M = {}

--
-- This properly puts together the correct output table that we want to
-- inject at a new position.
--
local function build_new_inject_string(input)
    local result_table = {}
    for _, args in ipairs(input) do
        if #args.parts > 1 then
            local tp = vim.iter(args.parts):take(#args.parts - 1):totable()
            local tip = vim.iter(args.parts):last()
            local existing_table = utils.get_set_table_path(result_table, tp)
            if not existing_table then
                utils.get_set_table_path(result_table, tp, { tip })
            else
                table.insert(existing_table, tip)
            end
        elseif #args.parts == 1 then
            table.insert(result_table, args.parts[1])
        end
    end
    local stringified = vim.split(vim.inspect(result_table), "\n")
    if #stringified > 2 then
        -- trim surrounding braces {...}
        table.remove(stringified, 1)
        table.remove(stringified)
    else
        stringified = { string.sub(stringified[1], 2, -2) }
    end
    log.debug(stringified)

    return stringified
end

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
function ts_tbl_path(ts_table_constr, t_path)
    local ret = { t_path_left = vim.deepcopy(t_path) }
    local depth = 0

    ---@param table_constructor_wrapper TS node wrapper of table constructor
    local function ts_root_mod_tbl_try_find_target(ts_tbl_in)
        depth = depth + 1
        print(string.format("--------------- %s ---------------", depth))
        ret.parent_table_node = ts_tbl_in
        ret.deepest_matched_table_node = ts_tbl_in -- this is only used for the initial sorting, which feels a bit unnecessary.

        -- TODO: use iterator instead!!

        -- for count, key, value, field in ts_tbl_in:iter_fields() do
        --     print(string.format("#%s: key(%s), value(%s), field(%s)", count, key, value, field))
        -- end

        if #ret.t_path_left > 1 then -- check branches
            local branch, ts_tbl_child

            for count, key, value, field in ts_tbl_in:iter_fields() do
                -- print(string.format("#%s: key(%s), value(%s), field(%s)", count, key, value, field))
                -- print("is_key:", field:is_key(), key, tostring(key))
                if field:is_key() and tostring(key) == ret.t_path_left[1]:upper() then
                    branch = true
                    ts_tbl_child = value
                    table.remove(ret.t_path_left, 1)
                end
            end

            -- ts_tbl_in:fields({
            --     on_key = {
            --         ret.t_path_left[1]:upper(),
            --         function(_, ts_value)
            --             branch = true
            --             ts_tbl_child = ts_value
            --             table.remove(ret.t_path_left, 1)
            --         end,
            --     },
            -- })
            return not branch and ret or ts_root_mod_tbl_try_find_target(ts_tbl_child)
        elseif #ret.t_path_left == 1 then -- handle indexed fields | for each table

            for count, key, value, field in ts_tbl_in:iter_fields() do
                if field:is_index() and value:type() == "table_constructor" then
                    local table_leaf = value
                    for count, leaf_key, leaf_value, field in table_leaf:iter_fields() do
                        if field:is_index() and leaf_key == 1 then
                            ret.module_found_node = table_leaf
                            ret.deepest_matched_table_node = table_leaf
                            ret.module_name_node = leaf_value
                        end
                    end
                    if not ret.module_found_node then
                        return ret
                    end
                    for count, leaf_key, leaf_value, field in table_leaf:iter_fields() do
                        if field:is_key() and tostring(leaf_key) == "enabled" then
                            ret.module_field_enabled_value_node = ts_value
                        end
                    end
                end
            end

            -- ts_tbl_in:fields({
            --     on_index = {
            --         type = "table",
            --         action = function(table_leaf)
            --             table_leaf:fields({
            --                 on_index = {
            --                     index = 1,
            --                     type = "string",
            --                     equals = ret.t_path_left[1],
            --                     action = function(str)
            --                         ret.module_found_node = table_leaf
            --                         ret.deepest_matched_table_node = table_leaf
            --                         ret.module_name_node = str
            --                     end,
            --                 },
            --             })
            --             if not ret.module_found_node then
            --                 return ret
            --             end
            --             table_leaf:fields({
            --                 on_key = {
            --                     "enabled",
            --                     function(key, ts_value)
            --                         ret.module_field_enabled_value_node = ts_value
            --                         -- print(vim.inspect(ts_value))
            --                         -- ts_value:toggle()
            --                     end,
            --                 },
            --             })
            --         end,
            --     },
            -- })
            table.remove(ret.t_path_left, 1)
        end
        return ret
    end
    return ts_root_mod_tbl_try_find_target(ts_table_constr)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(action)
    if not action.action then
        log.debug("No action was supplied")
        return
    end
    action = vim.deepcopy(action)

    local buf = dui_utils.get_buf_handle(utils.find_config("modules_test.lua"))
    local ts_buf = require("doom.utils.ts.lua"):new(buf)
    local query = "(return_statement (expression_list (table_constructor) @table_constructor))"
    -- print("ts_buf:", vim.inspect(ts_buf))
    local action_it = vim.iter(ipairs(action))
        :map(function(_, t)
            t.nodes = ts_tbl_path(ts_buf:query_wrap(query), t.t_path)
        end)
        :totable()

    table.sort(action, function(a, b)
        -- TODO: Maybe instead do
        -- if module_node then sort based on it, or else sort based on parent_node
        return a.nodes.deepest_matched_table_node:range()
            < b.nodes.deepest_matched_table_node:range()
    end)

    -- print("action table post [ts_root_mod_tbl_try_find_target]:", vim.inspect(action))

    -- Collect multiple edits and apply in correct order at once.
    local injection_nodes = {}

    for i = #action, 1, -1 do
        local t = action[i]
        local tn = t.nodes

        if action.action == "TOGGLE" then
            tn.module_field_enabled_value_node:toggle()
        end
        if action.action == "ENABLE" then
            tn.module_field_enabled_value_node:set(true)
        end
        if action.action == "DISABLE" then
            tn.module_field_enabled_value_node:set(false)
        end
        if action.action == "REMOVE" then
            tn.module_found_node:remove({ up_to = "first_sibling" })
        end

        --
        -- Handle case which requires injecting a new tree, ie. for each new
        -- target, build the insertion tree from the ancestor that exists.
        --

        if action.action == "ADD" then
            local id = tn.parent_table_node:id()
            local t_injectable
            for i, v in ipairs(injection_nodes) do
                if v.node:id() == id then
                    t_injectable = v
                end
            end
            if not t_injectable then
                t_injectable = {
                    parent_table_node = tn.parent_table_node,
                    injection_table = {},
                }

                table.insert(injection_nodes, t_injectable)
            end
            setmetatable(t_injectable, {
                __index = tn.parent_table_node, -- fallback/ makes TSNode methods available directly
            })

            local t_path_new_segment = vim.deepcopy(tn.t_path_left)
            table.remove(t_path_new_segment) -- remove last item, ie. the module name

            t_path_new_segment = vim.iter(t_path_new_segment)
                :map(function(v)
                    return v:upper()
                end)
                :totable()

            local new_name, new_branch
            if #t_path_new_segment > 0 then
                new_name = tn.t_path_left[#tn.t_path_left]
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
                new_name = t.t_path[#t.t_path]
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
                data = build_new_inject_string2(injectable.injection_table),
            })
        end
    end

    -- -- format and save
    -- -- Is formatting async?!
    -- vim.api.nvim_buf_call(buf, function()
    --     vim.lsp.buf.format({ async = false })
    --     vim.cmd("write")
    --     log.info("DUI: TS transform modules.lua -> lsp.buf.formatted()")
    -- end)
    -- log.info(("dui :: transformed modules.lua / action: %s"):format(opts.action))
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
        [[-------------------------------------------------------
-- manage_modules: #actions: %s
-------------------------------------------------------]],
        #opts
    ))

    -- TODO: rename `opts` to `actions`

    for i, action in ipairs(opts) do
        print(i, "Action:", vim.inspect(action))
        local ok = transform_enabled_modules_tree(action)
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

    if true then
        return
    end

    -- TODO: I have to allow for passing a set of multiple module paths
    -- create / remove multiple modules.
    -- >>> Gather all actions and only perform reloading / updating stuff
    -- with lazy after all async actions have been gathered.

    -- local actions = vim.iter(to_install)
    --     :map(function(entry)
    --         return nio.create(function()
    --             local future = nio.control.future()
    --             require("rocks.api").install(entry.name, entry.version, {
    --                 callback = function()
    --                     future.set(true)
    --                 end,
    --             })
    --             future.wait()
    --         end)
    --     end)
    --     :totable()
    -- nio.gather(actions)

    -- Async handle dir operations
    nio.run(function()
        helpers.semaphore.with(function()
            if opts.action == "ADD" and not path_init_file:exists() then
                local ok = module__create_dir_await(path_init_file, opts.target_module_name) -- .wait()
                if ok then
                    log.info(("DUI :: Success creating new module: %s"):format(path_init_file))
                    open_file(path_init_file, "current")
                end
            elseif opts.action == "TOGGLE" then
            -- toggle doesnt require any fs operations
            elseif opts.action == "ENABLE" then
            elseif opts.action == "DISABLE" then
            elseif opts.action == "MOVE" then
            -- moving dirs does require fs op
            elseif opts.action == "REMOVE" then
                local ok = module__dir_remove_async(opts.target_module_dir:tostring())
                if ok then
                    log.info("DUI: Success removing dir:", opts.target_module_dir:tostring())
                end
            end
        end)
    end)
end

return M
