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
            and txt(child_node:named_child(), args.buf):match('-- "([%w_]-)",') == args.parts[1]
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

local function get_node_analyze(t_path_new_segment)
  local rootfile = "modules.lua"
  local rootbuf = dui_utils.get_buf_handle(utils.find_config(rootfile))
  local parser = vim.treesitter.get_parser(rootbuf, "lua", {})
  local tree = parser:parse()[1]
  local root = tree:root()

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
  }

  -- print("ARG =", vim.inspect(arg))

  return ts_root_mod_tbl_try_find_target(arg)
end

---Handles adding, toggling, and removing modules from `./modules.lua`.
local function transform_enabled_modules_tree(opts)
  -- setup
  local got_leaves_only = true
  local ts_module_node_info = {}

  print("transform enabled modules ???")

  vim.iter(opts.targets):each(function(elem)
    -- Get table path of target module table
    local table_path = vim.split(elem.m_init_file:tostring():match("modules/(.-)/init.lua$"), "/")

    print("-------------------------")
    print("-- node analyze:")
    local args = get_node_analyze(table_path)

    print(">> [res] =", vim.inspect(args))
    print(args.ret.nodes.parent:range())

    if not args.ret.nodes.module then
      got_leaves_only = false
      args.range = args.ret.nodes.parent:range()
    else
      args.range = args.ret.nodes.module:range()
    end

    table.insert(ts_module_node_info, args)
  end)

  table.sort(ts_module_node_info, function(a, b)
    return a.range < b.range
  end)

  P(ts_module_node_info)


  -- local parent_range = { args.ret.nodes.parent:range() }
  -- local parent_last_line = (vim.api.nvim_buf_get_lines(
  --   args.buf,
  --   parent_range[3] - 1,
  --   parent_range[3],
  --   true
  -- ))[1]
  --
  -- -- if not action then
  -- --   action = args.ret.nodes.module and "toggle" or "add"
  -- -- end
  --
  -- -- local ensure_is_table_end = parent_last_line:match("^%s*},")
  --
  -- print(
  --   ("action = %s | last lines = `%s`, match = %s"):format(
  --     opts.action,
  --     vim.inspect(parent_last_line),
  --     parent_last_line:match("^%s*},")
  --   )
  -- )

  -- act

  if true then
    return
  end

  if opts.action == "TOGGLE" then
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
  elseif opts.action == "ENABLE" then
  elseif opts.action == "DISABLE" then
  elseif opts.action == "ADD" then
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

    local parent_range = { args.ret.nodes.parent:range() }

    vim.api.nvim_buf_set_lines(
      args.buf,
      parent_range[1] + 1,
      parent_range[1] + 1,
      true,
      { str }
    )
  elseif opts.action == "REMOVE" then
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
    log.error("Dui requires nio and pathlib for async.")
    return
  end

  if not vim.iter(opts.targets):all(function(k, v)
        -- This is not bulletproof!
        return k.target_module_dir:match("nvim/lua/doom/modules") or
            k.target_module_dir:match("nvim/lua/user/modules")
      end)
  then
    -- log.info("manage_modules_tree > Validate input: Some targets were invalid OR not doom modules.")
    log.error("ABORT: Dui module browser: target file is not a doom-nvim lua file")
    return
  end

  -- add init files
  opts.targets = vim.iter(opts.targets):map(function(entry)
    entry.m_init_file = entry.target_module_dir / "init.lua"
    return entry
  end):totable()

  -- for i, v in ipairs(opts.targets) do
  --   print(">>>", v.m_init_file)
  -- end

  -- Sync transform the modules.lua file
  transform_enabled_modules_tree(opts)

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
      if opts.action == "ADD" and not m_init_file:exists() then
        local ok = module__create_dir_await(m_init_file, opts.target_module_name) -- .wait()
        if ok then
          log.info(("DUI :: Success creating new module: %s"):format(m_init_file))
          open_file(m_init_file, "current")
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
