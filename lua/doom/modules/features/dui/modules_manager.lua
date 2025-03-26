local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local utils = require("doom.utils")

local txt = vim.treesitter.get_node_text

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
    -- trim surrounding braces {...}
    if #stringified > 2 then
        table.remove(stringified, 1)
        table.remove(stringified)
    else
        stringified = { string.sub(stringified[1], 2, -2) }
    end
    log.debug(stringified)

    return stringified
end

local ts = {}

-- PERF: Currently this func recursively searches the tree once for each
-- target path. Reduce this to only one recursive call, by for each leaf,
-- check against the list of target modules every time.
--
---Recurse down to the target module leaf in ./modules.lua tree.
---The target segment is availble on args.mod_path_table.
---@param args table Takes the form of
---         node = return_table_constructor, -- usually the returned table is passed as first input.
---         buf = rootbuf,
---         parts = t_path_new_segment,
---         is_comment?
---         ret = {
---           leaf_is_comment
---           nodes = {
---               parent
---               module // leaf_node?
---           }
---         }
---@return table The same table as <args>
local function ts_root_mod_tbl_try_find_target(args)
    print("## enter recursive:", vim.inspect(args))

    -- FIX: Ensure that args.node:type() == "table_constructor"

    if not args.ret then
        args.ret = {
            nodes = {},
        }
    end
    args.ret.nodes.parent = args.node
    if #args.parts > 1 then
        local branch
        for c in args.node:iter_children() do
            if
                c:type() == "field"
                and c:named_child_count() == 2
                and txt(c:named_child(0), args.buf) == args.parts[1]
            then
                print("branch:", txt(c:named_child(0), args.buf))
                branch = true
                args.node = c:named_child(1)
                table.remove(args.parts, 1)
            end
        end
        if not branch then
            return args
        end
        args = ts_root_mod_tbl_try_find_target(args)
    elseif #args.parts == 1 then
        for child_node in args.node:iter_children() do
            if child_node:named() and child_node:named_child_count() == 1 then
                if
                    child_node:type() == "comment"
                    and txt(child_node:named_child(), args.buf):match('-- "([%w_]-)",')
                        == args.parts[1]
                then
                    print("leaf: ", txt(child_node:named_child(), args.buf):match('-- "(%w-)",'))
                    args.ret.nodes.module = child_node
                    args.ret.leaf_is_comment = true
                elseif
                    child_node:type() == "field"
                    and txt(child_node:named_child():named_child(), args.buf) == args.parts[1]
                then
                    print("leaf: ", txt(child_node:named_child():named_child(), args.buf))
                    args.ret.nodes.module = child_node
                end
            end
        end
        -- table.remove(args.parts, 1)
    end
    return args
end

local function get_node_analyze(rootbuf, t_path_new_segment)
    local parser = vim.treesitter.get_parser(rootbuf, "lua", {})
    local root = parser:parse()[1]:root()

    -- Get the modules table constructor
    --   under the return statement

    local return_query = vim.treesitter.query.parse("lua", "(return_statement) @return")
    local return_table_constructor
    for _, capture_node, _ in return_query:iter_captures(root, rootbuf) do
        return_table_constructor = capture_node:named_child():named_child()
    end

    local arg = {
        node = return_table_constructor,
        buf = rootbuf,
        parts = t_path_new_segment,
        original_table_path = vim.deepcopy(t_path_new_segment),
    }

    -- print("ARG =", vim.inspect(arg))

    return ts_root_mod_tbl_try_find_target(arg)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(opts)
    local rootfile = "modules.lua"
    local modules_buf_handle = dui_utils.get_buf_handle(utils.find_config(rootfile))

    -- setup
    local ts_module_node_info = {}

    -- print("transform enabled modules ???")

    -- NOTE: if a full node is not found then that is not a problemi i just need
    -- to figure out how to handle the other way  and so
    -- this is goig to be a lot of fun you know and the
    -- thing is diddeli fuck sturp derperliz

    -- For each target, analyze the modules tree and return node data about
    -- each target to be used later.
    local count = 0
    vim.iter(opts.targets):each(function(target)
        -- Get table path of target module table
        count = count + 1

        local table_path
        if target.selected_module then
            table_path = vim.split(
                target.selected_module.path_init_file:match("modules/(.-)/init.lua$"),
                "/"
            )
        else
            table_path =
                vim.split(target.path_init_file:tostring():match("modules/(.-)/init.lua$"), "/")
        end

        print("-------------------------")
        print("-- node analyze:")
        log.info(
            string.format(
                "\n-------------------------------\n-- Node analyze #%s: module = [%s.%s.%s] \n--\n--",
                count,
                target.selected_module.origin,
                target.selected_module.section,
                target.selected_module[1]
            )
        )

        local args = get_node_analyze(modules_buf_handle, table_path)

        print(">> [res] =", vim.inspect(args))
        print(args.ret.nodes.parent:range())

        args.range = args.ret.nodes.module and args.ret.nodes.module:range()
            or args.ret.nodes.parent:range()

        table.insert(ts_module_node_info, args)
    end)

    -- sort elements so that we can perform all file operations in reverse.
    table.sort(ts_module_node_info, function(a, b)
        return a.range < b.range
    end)

    -- P(ts_module_node_info)
    log.info("ts_module_node_info SORTED:", ts_module_node_info)

    if #ts_module_node_info == 0 then
        log.debug("ts_module_node_info was empty. Aborting..")
        return
    end

    local function enable_module_line() end
    local function disable_module_line() end
    local function remove_module_line() end

    if not opts.action then
        log.debug("No action was supplied")
        return
    end

    -- local parent_range = { args.ret.nodes.parent:range() }
    -- local parent_last_line = (vim.api.nvim_buf_get_lines(
    --   args.buf,
    --   parent_range[3] - 1,
    --   parent_range[3],
    --   true
    -- ))[1]
    -- -- local ensure_is_table_end = parent_last_line:match("^%s*},")
    -- print(
    --   ("action = %s | last lines = `%s`, match = %s"):format(
    --     opts.action,
    --     vim.inspect(parent_last_line),
    --     parent_last_line:match("^%s*},")
    --   )
    -- )

    -- act

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

    if true then
        return
    end

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
                    args.buf,
                    module_range[1],
                    module_range[1] + 1,
                    true
                ))[1]

                -- TODO: refator these into enable_module_line() and disable_module_line()

                if args.ret.leaf_is_comment then
                    -- enable_module_line() -- from comment..
                    local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
                    vim.api.nvim_buf_set_text(
                        args.buf,
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
                        args.buf,
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
                --   args.buf,
                --   module_range[1],
                --   module_range[1] + 1,
                --   true
                -- ))[1]
                -- if args.ret.leaf_is_comment then
                --   local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
                --   vim.api.nvim_buf_set_text(
                --     args.buf,
                --     module_range[1],
                --     start_col - 1,
                --     module_range[1],
                --     end_col,
                --     {}
                --   )
                -- else
                --   local start_col, end_col = module_line:find('"') -- find first double quote
                --   vim.api.nvim_buf_set_text(
                --     args.buf,
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
                modules_buf_handle,
                parent_col_start + 1,
                parent_col_start + 1,
                true,
                t_inject_new_lines
            )
        elseif opts.action == "REMOVE" then
            -- Only remove module if it exists as a node.
            if args.ret.nodes.module then
                local module_range = { args.ret.nodes.module:range() }
                vim.api.nvim_buf_set_lines(args.buf, module_range[1], module_range[1] + 1, true, {})
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
    --       args.buf,
    --       module_range[1],
    --       module_range[1] + 1,
    --       true
    --     ))[1]
    --
    --     if args.ret.leaf_is_comment then
    --       local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
    --       vim.api.nvim_buf_set_text(
    --         args.buf,
    --         module_range[1],
    --         start_col - 1,
    --         module_range[1],
    --         end_col,
    --         {}
    --       )
    --     else
    --       local start_col, end_col = module_line:find('"') -- find first double quote
    --       vim.api.nvim_buf_set_text(
    --         args.buf,
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
    --       args.buf,
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
    --     vim.api.nvim_buf_set_lines(args.buf, module_range[1], module_range[1] + 1, true, {})
    --   else
    --     log.error("dui @ mod browser :: No valid action for root mod CRUD")
    --     return
    --   end
    -- end

    -- format and save
    vim.api.nvim_buf_call(modules_buf_handle, function()
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

    -- Handle when we are working with [ui_select_browser]
    if opts.targets.target_module_dir then
        if
            not vim.iter(opts.targets):all(function(k, v)
                -- This is not bulletproof!
                return k.target_module_dir:match("nvim/lua/doom/modules")
                    or k.target_module_dir:match("nvim/lua/user/modules")
            end)
        then
            -- log.info("manage_modules_tree > Validate input: Some targets were invalid OR not doom modules.")
            log.error("ABORT: Dui module browser: target file is not a doom-nvim lua file")
            return
        end

        -- TODO: if the input already has init file then ignore
        --
        -- add init files
        opts.targets = vim.iter(opts.targets)
            :map(function(entry)
                entry.path_init_file = entry.target_module_dir / "init.lua"
                return entry
            end)
            :totable()

        -- for i, v in ipairs(opts.targets) do
        --   print(">>>", v.path_init_file)
        -- end
        --
    end

    log.info("pre transform enabled modules tree. opts =", opts)

    local ok = transform_enabled_modules_tree(opts)
    -- NOTE: prevent adding files now during dev.
    if true or not ok then
        log.warn("Failure updating [modules.lua]. Aborting..")
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
