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

-- NOTE: This should also go into [doom.utils.ts.lua]
-- TODO: document
--
--- TS get set table path
--- TODO: now since the buf is attached to the ts_table_constr. and we are only
--- working with the new ts_lua obj and its children, I can just pass the ts_lua
--- obj directly.
function ts_tbl_path(ts_table_constr, t_path)

    -- print("INPUT -> ts_table_constr:", vim.inspect(ts_table_constr))

    local ret = { t_path_left = vim.deepcopy(t_path) }
    -- local TSLua = require("doom.utils.ts.lua"):new(buf)
    local TSLua = ts_table_constr
    local depth = 0

    -- TODO: we are only operating on the table wrapper, therefore we can
    -- just pass the table wrapper directly
    local function ts_root_mod_tbl_try_find_target(ts_tbl_in)
        -- local TSModSection = TSLua(ts_tbl_in)
        local TSModSection = ts_tbl_in
        depth = depth + 1
        -- print("???", vim.inspect(ts_tbl_in:get_node()))
        print("TSModSection", vim.inspect(TSModSection))

        ret.ts_node_tbl_parent = ts_tbl_in:get_node()
        ret.deepest_matched_table = ts_tbl_in:get_node()

        print("ts_node_tbl_parent range ->", ts_tbl_in:get_node():range())

        print(string.format("--------------- %s\n ret: %s", depth, vim.inspect(ret)))
        if #ret.t_path_left > 1 then -- check branches
            local branch, ts_tbl_child
            TSModSection:fields({
                on_key = {
                    ret.t_path_left[1]:upper(),
                    function(buf, key, value)
                        branch = true
                        ts_tbl_child = value
                        table.remove(ret.t_path_left, 1)
                    end,
                },
            })
            return not branch and ret or ts_root_mod_tbl_try_find_target(TSModSection(ts_tbl_child))
        elseif #ret.t_path_left == 1 then -- handle indexed fields | for each table
            TSModSection:fields({
                on_index = {
                    type = "table",
                    action = function(buf, value_table)
                        local TSModTbl = TSLua(value_table)
                        TSModTbl:fields({
                            on_index = {
                                index = 1,
                                type = "string",
                                equals = ret.t_path_left[1],
                                action = function(buf, str, content)
                                    ret.ts_module_found = value_table
                                    ret.deepest_matched_table = value_table
                                    ret.module = true
                                    ret.module_real_name = TSLua:text(content)
                                    ret.deepest_name = TSLua:text(content)
                                    ret.module_name_string = str
                                    ret.module_range = { value_table:range() }
                                end,
                            },
                        })
                        if not ret.module then
                            -- print("on_table is NOT is_module")
                            ret.parent = true
                            return ret
                        end
                        TSModTbl:fields({
                            on_key = {
                                "enabled",
                                function(buf, key, value)
                                    ret.ts_enabled_value = value
                                    ret.ts_module_enabled_value = TSLua:text(value) == "true"
                                            and true
                                        or false
                                end,
                            },
                        })
                    end,
                },
            })
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

    -- FIX: the classes are setup in a bit stupid way so i should get the buf
    -- from
    local buf = dui_utils.get_buf_handle(utils.find_config("modules_test.lua"))
    local ts_buf = require("doom.utils.ts.lua"):new(buf)

    print("ts_buf:", vim.inspect(ts_buf))

    local action_it = vim.iter(ipairs(action))
        :map(function(_, t)
            -- should pass the first ts_table_constructer obj directly, instead of passing the buf and query.
            -- TODO: ts_buf:query_wrap(..)
            -- >>>> see if we can call self inside the method to return a new wrapped table instance
            local ts_tbl = ts_buf:query_wrap([[(return_statement (expression_list (table_constructor) @table_constructor))]])

            -- print("ts_tbl:", vim.inspect(ts_tbl))
            t.nodes = ts_tbl_path(ts_tbl, t.t_path)
        end)
        :totable()
    table.sort(action, function(a, b)
        return a.nodes.deepest_matched_table:range() < b.nodes.deepest_matched_table:range()
    end)

    print("action table post [ts_root_mod_tbl_try_find_target]:", vim.inspect(action))

    -- if true then return end

    -- Collect multiple edits and apply in correct order at once.
    local injection_nodes = {}

    -- NOTE: toggling + ableing: only changes existing tables.
    -- NOTE: removing + adding: requires new trees

    for i = #action, 1, -1 do
        local t = action[i]
        local tn = t.nodes

        --
        -- Handle simple actions, ie. that only requires updating table values
        -- of existing module tables.
        --

        if action.action == "TOGGLE" then
            ts:replace(tn.ts_enabled_value, tostring(not tn.ts_module_enabled_value))
        end
        if action.action == "ENABLE" then
            ts:replace(tn.ts_enabled_value, tostring(true))
        end
        if action.action == "DISABLE" then
            ts:replace(tn.ts_enabled_value, tostring(false))
        end
        if action.action == "REMOVE" then
            ts.tbl.field.remove(tn.ts_module_found)
            -- FIX: wrap in TSLuaTable and use field.remove.
            -- local TSModuleFound = ts.TSLuaTable(buf, tn.ts_module_found)
            -- TSModuleFound:remove({ until = "first_sibling"})
        end

        --
        -- Handle case which requires injecting a new tree, ie. for each new
        -- target, build the insertion tree from the ancestor that exists.
        --

        if action.action == "ADD" then
            local id = tn.ts_node_tbl_parent:id()
            local t_inject
            for i, v in ipairs(injection_nodes) do
                if v.node:id() == id then
                    t_inject = v
                end
            end
            if not t_inject then
                t_inject = {
                    node = tn.ts_node_tbl_parent,
                    tree = {},
                }
                table.insert(injection_nodes, t_inject)
            end
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
                new_branch = utils.get_set_table_path(t_inject.tree, t_path_new_segment)
                if not new_branch then
                    new_branch = {}
                    utils.get_set_table_path(t_inject.tree, t_path_new_segment, new_branch)
                end
            else
                new_name = t.t_path[#t.t_path]
                new_branch = t_inject.tree
            end

            table.insert(new_branch, { new_name, enabled = true })
        end
    end

    -- inject new trees.
    if #injection_nodes > 0 then
        table.sort(injection_nodes, function(a, b)
            return a.node:range() > b.node:range()
        end)

        for i, v in ipairs(injection_nodes) do
            print(i, "sorted range:", v.node:range())
            print("tree:", vim.inspect(v.tree))
            local t_stringified = build_new_inject_string2(v.tree)
            print("ret -> TREE STRINGIFIED:", vim.inspect(t_stringified))
            local parent_range = { v.node:range() }
            local row, col = parent_range[1], parent_range[2] + 1
            vim.api.nvim_buf_set_text(buf, row, col, row, col, t_stringified)

            -- TODO: move this into the table class.
            -- local TSModTableInsert = ts.TSLuaTable(buf, v.node)
            -- TSModTableInsert:add_field_from_text({ data = t_stringified, pos = "first" })
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
