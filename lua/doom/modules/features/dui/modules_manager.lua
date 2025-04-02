local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local utils = require("doom.utils")

local ts = require("doom.utils.ts")

local pu = require("doom.modules.features.dui.templates")
local dui_utils = require("doom.modules.features.dui.utils")

local M = {}

--
-- This properly puts together the correct output table that we want to
-- inject at a new position.
--
local function build_new_inject_string(ranges)
    local result_table = {}
    for _, args in ipairs(ranges) do
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

-- NOTE: This should also go into [doom.utils.ts]
-- TODO: document
--
--- TS get set table path
function tsgst(buf, ts_node_table, t_path)
    if ts_node_table:type() ~= "table_constructor" then
        log.error("Only accepts table_constructor nodes!")
        return
    end
    local ret = { t_path_left = vim.deepcopy(t_path) }
    local TSLua = ts.TSLua(buf)
    local depth = 0

    local function ts_root_mod_tbl_try_find_target(ts_tbl_in)
        local TSModSection = ts.TSLuaTable(buf, ts_tbl_in)
        depth = depth + 1
        ret.ts_node_tbl_parent = ts_tbl_in
        ret.deepest = ts_tbl_in

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
            return not branch and ret or ts_root_mod_tbl_try_find_target(ts_tbl_child)
        elseif #ret.t_path_left == 1 then -- handle indexed fields | for each table
            TSModSection:fields({
                on_index = {
                    type = "table",
                    action = function(buf, value_table)
                        local TSModTbl = ts.TSLuaTable(buf, value_table)
                        TSModTbl:fields({
                            on_index = {
                                index = 1,
                                type = "string",
                                equals = ret.t_path_left[1],
                                action = function(buf, str, content)
                                    ret.module_table_constructor = value_table
                                    ret.deepest = value_table
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
                                    ret.module_enabled = TSLua:text(value) == "true" and true
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
    return ts_root_mod_tbl_try_find_target(ts_node_table)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(action)
    action = vim.deepcopy(action)
    local rootfile = "modules.lua"
    local buf = dui_utils.get_buf_handle(utils.find_config(rootfile))

    -- TODO: this should go into the TS base class.
    -- Get the [modules.lua] modules table ts table constructor.
    --
    -- Add the filetype and query.
    -- Add method to get first node found from query.
    --
    -- :query([[(table_constructor)]])
    --
    local parser = vim.treesitter.get_parser(buf, "lua", {})
    local root = parser:parse()[1]:root()
    local return_query = vim.treesitter.query.parse("lua", [[(return_statement) @return]])
    local ts_tbl
    for _, capture_node, _ in return_query:iter_captures(root, buf) do
        ts_tbl = capture_node:named_child():named_child()
    end

    local action_iter = vim.iter(ipairs(action)):map(function(_, t)
        t.nodes = tsgst(buf, ts_tbl, t.t_path)
    end):totable()

    table.sort(action, function(a, b)
        return a.nodes.deepest:range() < b.nodes.deepest:range()
    end)

    print("action table post [ts_root_mod_tbl_try_find_target]:", vim.inspect(action))

    local function enable_module_line() end
    local function disable_module_line() end
    local function remove_module_line() end

    if not action.action then
        log.debug("No action was supplied")
        return
    end

    local edits = {}

    -- When building new module sections for insertion, index each new section
    -- by the parent table's node id, which allows for simply looping over the
    -- nodes by starting_line, and then injecting key at the end.
    local id_2_new_section = {}

    -- TEST: Because the table is sorted. Now i could just iter it again, and
    -- hopefully the iter order will probably be correct.

    for i = #action, 1, -1 do
        local t = action[i]
        local tn = t.nodes

        print(string.rep("?", i))

        -- -- Toggling modules implies there existence, which means that we can directly
        -- -- just replace the modules values.
        -- if action.action == "TOGGLE" then
        --     ts:replace(tn.ts_enabled_value, tostring(not tn.module_enabled))
        -- end
        -- if action.action == "ENABLE" then
        --     ts:replace(tn.ts_enabled_value, tostring(true))
        -- end
        -- if action.action == "DISABLE" then
        --     ts:replace(tn.ts_enabled_value, tostring(false))
        -- end
        -- if action.action == "REMOVE" then
        --     ts.tbl.field.remove(tn.module_table_constructor)
        -- end

        -- this should be enough to build proper injection strings.
        if action.action == "ADD" then
            local t_path_new_segment = tn.t_path_left

            -- TODO:
            -- 1. rename selected_module to target_module.
            --      Now when we do tsgst() each return
            --      will represent the parent table to which we should inject
            --      the new table.
            -- 2.

            table.insert(t_path_new_segment, 1, tn.ts_node_tbl_parent:id())
            table.remove(tsgst) -- remove last item, ie. the module name

            utils.get_set_table_path(
                id_2_new_section,
                t_path_new_segment,
                { tn.t_path_left[#t_path_left], enabled = true }
            )
        end

        if action.action == "MOVE" then
            -- 1. collect all old deletion edits.
        end
    end

    log.info("id_2_new_section", id_2_new_section)

    if true then
        return
    end

    -- might need to put all IDs in order in an array so that we can loop over the
    -- IDs in order with ipair
    if #id_2_new_section > 0 then
        -- revers loop paren not id start lines and inject in correct order.
    end

    local args_by_range = {}
    local order = {}

    vim.iter(ts_module_node_info):rev():each(function(el)
        if not args_by_range[el.range] then
            args_by_range[el.range] = {}
            table.insert(order, el.range)
        end
        table.insert(args_by_range[el.range], el)
    end)

    print("<ARGS MAPPED BY RANGE>")

    -- Reverse loop each injection range.
    vim.iter(order):each(function(i)
        local current_range = i
        local ranges = args_by_range[i]
        print("---------------------------------------")

        -- WARN: Prevent any changes during dev.
        if true then
            return
        end

        local is_mult = #ranges > 1
        local single_new = not ranges[1].ret.nodes.module

        if opts.action == "TOGGLE" then
            if is_mult or single_new then
            -- TODO: build string to inject new modules as `enabled`
            -- >>> Call action ADD
            --      Just add new (*)
            --      Remember: mult or single -> new means that we are only
            --      adding modules, ie. no commenting/toggling.
            else
                -- Toggle single lines / modules, ie one module line per range
                local args = ranges[1]
                local module_range = { args.ret.nodes.module:range() }
                local module_line = (vim.api.nvim_buf_get_lines(
                    buf,
                    module_range[1],
                    module_range[1] + 1,
                    true
                ))[1]

                -- TODO: refator these into enable_module_line() and disable_module_line()

                if args.ret.leaf_is_comment then
                    -- enable_module_line() -- from comment..
                    local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
                    vim.api.nvim_buf_set_text(
                        buf,
                        module_range[1],
                        start_col - 1,
                        module_range[1],
                        end_col,
                        {}
                    )
                else
                    -- disable_module_line() -- from regular module name string.
                    local start_col, end_col = module_line:find('"') -- find first double quote
                    vim.api.nvim_buf_set_text(
                        buf,
                        module_range[1],
                        start_col - 1,
                        module_range[1],
                        end_col - 1,
                        { "-- " }
                    )
                end
            end
        elseif opts.action == "ENABLE" then
            -- TODO: ts.tbl.iter
            -- TODO: ts.types.bool.toggle
            -- TODO: ts.args.sort
            -- TODO: ts.args.iter

            if is_mult or single_new then
            -- TODO: build string to inject new modules as `enabled`
            -- >>> Call action ADD
            --      Just add new (*)
            else
                -- -- Toggle existing single module
                -- local args = ranges[1]
                -- local module_range = { args.ret.nodes.module:range() }
                -- local module_line = (vim.api.nvim_buf_get_lines(
                --   buf,
                --   module_range[1],
                --   module_range[1] + 1,
                --   true
                -- ))[1]
                -- if args.ret.leaf_is_comment then
                --   local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
                --   vim.api.nvim_buf_set_text(
                --     buf,
                --     module_range[1],
                --     start_col - 1,
                --     module_range[1],
                --     end_col,
                --     {}
                --   )
                -- else
                --   local start_col, end_col = module_line:find('"') -- find first double quote
                --   vim.api.nvim_buf_set_text(
                --     buf,
                --     module_range[1],
                --     start_col - 1,
                --     module_range[1],
                --     end_col - 1,
                --     { "-- " }
                --   )
                -- end
            end
        elseif opts.action == "DISABLE" then
            if is_mult or single_new then
                -- TODO: build string to inject new modules as `enabled`
                -- >>> Call action ADD as disabled
                --      Get the inject string BUT apply a comment prefix to each
                --      module entry.
                print("!!")
            else
                -- single add comment prefix
                print("!!")
                -- TODO: If not disabled, then disable_module_line,
                -- else enable_module_line
            end
        elseif opts.action == "ADD" then
            local t_inject_new_lines = build_new_inject_string(ranges)

            -- local pre = ""
            -- local post = ""
            -- local str
            -- for i, v in ipairs(args.parts) do
            --   if i < #args.parts then
            --     pre = pre .. v .. " = {"
            --     post = post .. "},"
            --   else
            --     str = ([[%s "%s", %s]]):format(pre, v, post)
            --   end
            -- end

            local parent_col_start = current_range
            -- inject_lines_at_col()
            vim.api.nvim_buf_set_lines(
                buf,
                parent_col_start + 1,
                parent_col_start + 1,
                true,
                t_inject_new_lines
            )
        elseif opts.action == "REMOVE" then
            -- Only remove module if it exists as a node.
            if args.ret.nodes.module then
                local module_range = { args.ret.nodes.module:range() }
                vim.api.nvim_buf_set_lines(buf, module_range[1], module_range[1] + 1, true, {})
            end
        else
            log.error("dui @ mod browser :: No valid action for root mod CRUD")
            return
        end
    end)

    -- for i, el in pairs(args_by_range) do
    --   print(i)
    -- end

    -- if true then
    --   return
    -- end
    --
    -- for i = 1, #reversed, 1 do
    --   local args = reversed[i]
    --
    --   if opts.action == "TOGGLE" then
    --     local module_range = { args.ret.nodes.module:range() }
    --     local module_line = (vim.api.nvim_buf_get_lines(
    --       buf,
    --       module_range[1],
    --       module_range[1] + 1,
    --       true
    --     ))[1]
    --
    --     if args.ret.leaf_is_comment then
    --       local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
    --       vim.api.nvim_buf_set_text(
    --         buf,
    --         module_range[1],
    --         start_col - 1,
    --         module_range[1],
    --         end_col,
    --         {}
    --       )
    --     else
    --       local start_col, end_col = module_line:find('"') -- find first double quote
    --       vim.api.nvim_buf_set_text(
    --         buf,
    --         module_range[1],
    --         start_col - 1,
    --         module_range[1],
    --         end_col - 1,
    --         { "-- " }
    --       )
    --     end
    --   elseif opts.action == "ENABLE" then
    --   elseif opts.action == "DISABLE" then
    --   elseif opts.action == "ADD" then
    --     local pre = ""
    --     local post = ""
    --     local str
    --
    --     for i, v in ipairs(args.parts) do
    --       if i < #args.parts then
    --         pre = pre .. v .. " = {"
    --         post = post .. "},"
    --       else
    --         str = ([[%s "%s", %s]]):format(pre, v, post)
    --       end
    --     end
    --
    --     local parent_range = { args.ret.nodes.parent:range() }
    --
    --     vim.api.nvim_buf_set_lines(
    --       buf,
    --       parent_range[1] + 1,
    --       parent_range[1] + 1,
    --       true,
    --       { str }
    --     )
    --   elseif opts.action == "REMOVE" then
    --     if not args.ret.nodes.module then
    --       return false
    --     end
    --     local module_range = { args.ret.nodes.module:range() }
    --     vim.api.nvim_buf_set_lines(buf, module_range[1], module_range[1] + 1, true, {})
    --   else
    --     log.error("dui @ mod browser :: No valid action for root mod CRUD")
    --     return
    --   end
    -- end

    -- format and save
    vim.api.nvim_buf_call(buf, function()
        vim.lsp.buf.format({ async = false })
        vim.cmd("write")
        log.info("DUI: TS transform modules.lua -> lsp.buf.formatted()")
    end)
    log.info(("dui :: transformed modules.lua / action: %s"):format(opts.action))
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
