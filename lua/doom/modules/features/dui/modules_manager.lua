local utils = require("doom.utils")
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")

local ts = vim.treesitter

local txt = ts.get_node_text

local pu = require("doom.modules.features.dui.templates")
local dui_utils = require("doom.modules.features.dui.utils")


local M = {}


---Recurse down to the target module leaf in ./modules.lua tree.
---The target segment is availble on args.mod_path_table.
---@param args table Takes the form of
---         node = return_table_constructor,
---         buf = rootbuf,
---         parts = t_path_new_segment,
---         is_comment?
---         ret = {
---           leaf_is_comment
---           nodes = {
---               parent
---               leaf_node?
---           }
---         }
---@return table The same table as <args>
local function ts_root_mod_tbl_try_find_target(args)
    print("## enter recursive:", vim.inspect(args))
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
        for c in args.node:iter_children() do
            if c:named() and c:named_child_count() == 1 then
                if
                    c:type() == "comment"
                    and txt(c:named_child(), args.buf):match('-- "([%w_]-)",') == args.parts[1]
                then
                    print("leaf: ", txt(c:named_child(), args.buf):match('-- "(%w-)",'))
                    args.ret.nodes.module = c
                    args.ret.leaf_is_comment = true
                elseif
                    c:type() == "field"
                    and txt(c:named_child():named_child(), args.buf) == args.parts[1]
                then
                    print("leaf: ", txt(c:named_child():named_child(), args.buf))
                    args.ret.nodes.module = c
                end
            end
        end
        -- table.remove(args.parts, 1)
    end
    return args
end

local function get_node_analyze(t_path_new_segment)
    local rootfile = "modules.lua"
    local rootbuf = dui_utils.get_buf_handle(utils.find_config(rootfile))
    local parser = vim.treesitter.get_parser(rootbuf, "lua", {})
    local tree = parser:parse()[1]
    local root = tree:root()
    -- get the modules table constructor under the return statement
    local return_query = vim.treesitter.query.parse("lua", "(return_statement) @return")
    local return_table_constructor
    for _, capture_node, _ in return_query:iter_captures(root, rootbuf) do
        return_table_constructor = capture_node:named_child():named_child()
    end

    local arg = {
        node = return_table_constructor,
        buf = rootbuf,
        parts = t_path_new_segment,
    }

    -- print("ARG =", vim.inspect(arg))

    return ts_root_mod_tbl_try_find_target(arg)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(new_module_file, action)
    local table_path = vim.split(new_module_file:tostring():match("modules/(.-)/init.lua$"), "/")
    local args = get_node_analyze(table_path)

    print(">> [res] =", vim.inspect(args))
    print(args.ret.nodes.parent:range())

    local parent_range = { args.ret.nodes.parent:range() }
    local parent_last_line = (vim.api.nvim_buf_get_lines(
        args.buf,
        parent_range[3] - 1,
        parent_range[3],
        true
    ))[1]

    -- if not action then
    --   action = args.ret.nodes.module and "toggle" or "add"
    -- end

    -- local ensure_is_table_end = parent_last_line:match("^%s*},")

    print(
        ("action = %s | last lines = `%s`, match = %s"):format(
            action,
            vim.inspect(parent_last_line),
            parent_last_line:match("^%s*},")
        )
    )

    if action == "TOGGLE" then
        local module_range = { args.ret.nodes.module:range() }
        local module_line = (vim.api.nvim_buf_get_lines(
            args.buf,
            module_range[1],
            module_range[1] + 1,
            true
        ))[1]

        if args.ret.leaf_is_comment then
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
    elseif action == "ADD" then
        local pre = ""
        local post = ""
        local str

        for i, v in ipairs(args.parts) do
            if i < #args.parts then
                pre = pre .. v .. " = {"
                post = post .. "},"
            else
                str = ([[%s "%s", %s]]):format(pre, v, post)
            end
        end

        vim.api.nvim_buf_set_lines(
            args.buf,
            parent_range[1] + 1,
            parent_range[1] + 1,
            true,
            { str }
        )
    elseif action == "REMOVE" then
        if not args.ret.nodes.module then
            return false
        end
        local module_range = { args.ret.nodes.module:range() }
        vim.api.nvim_buf_set_lines(args.buf, module_range[1], module_range[1] + 1, true, {})
    else
        log.error("dui @ mod browser :: No valid action for root mod CRUD")
    end

    -- format and save
    vim.api.nvim_buf_call(args.buf, function()
        vim.lsp.buf.format({ async = false })
        vim.cmd("write")
        log.info("DUI: TS transform modules.lua -> lsp.buf.formatted()")
    end)
    log.info(("dui :: transformed modules.lua / action: %s"):format(action))
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
    local helpers = require("doom.modules.features.dui.operations.helpers")
    if not nio or not Path then
        log.error("Dui requires nio and pathlib for async.")
        return
    end
    if
        not (
            opts.target_module_dir:match("nvim/lua/doom/modules")
            or opts.target_module_dir:match("nvim/lua/user/modules")
        )
    then
        log.error("ABORT: Dui module browser: target file is not a doom-nvim lua file")
        return
    end
    local m_init_file = opts.target_module_dir / "init.lua"

    -- Sync transform the modules.lua file
    transform_enabled_modules_tree(m_init_file, opts.action)

    -- Async handle dir operations
    nio.run(function()
        helpers.semaphore.with(function()
            if opts.action == "ADD" and not m_init_file:exists() then
                local ok = module__create_dir_await(m_init_file, opts.target_module_name) -- .wait()
                if ok then
                    log.info(("DUI :: Success creating new module: %s"):format(m_init_file))
                    open_file(m_init_file, "current")
                end
            elseif opts.action == "TOGGLE" then
            elseif opts.action == "MOVE" then
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
