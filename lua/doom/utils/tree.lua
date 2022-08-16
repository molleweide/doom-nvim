local M = {}

-- TODO: only log if the log flag is passed with opts.

local log = {
  sep = "*---",
  type = "modules",
  use = true,
  leaf = true,
  branch = true,
}

-- todo: move to "core/spec.lua"
local MODULE_PARTS = {
  "settings",
  "packages",
  "configs",
  "binds",
  "cmds",
  "autocmds",
}

-- Helper for creating indentation based on the stack length
--
-- @param recursive stack
local function compute_indentation(stack)
  local a = ""
  for _ = 0, #stack do
    a = a .. log.sep
  end
  return a .. ">"
end

-- Helper tool for debuggin the traversal
--
--
local function logger(pre, opts, stack, k, v)
  -- if log.use and opts.type == log.type then
  --   print(opts.type, "|[", pre, "]", compute_indentation(stack), k, v)
  -- end
  if opts.log then
    print(opts.type, "|[", pre, "]", compute_indentation(stack), k, v)
  end
end

--- Concatenates the stack with the leaf node.
---
---@returns the full path to leaf as an array
local function flatten_stack(stack, v)
  local pc = { v }
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, v)
  end
  return pc
end

-- Helper for attaching data to a specific table path in `head` table. Eg. `doom.modules`
-- could be a head if you want to append all modules upon loading doom.
--
---@param table | pointer to which you want to append
---@param table | path to append
---@param data | leaf node data that will be appended at the tip of path
---@return todo..
M.attach_table_path = function(head, tp, data)
  local last = #tp
  for i, p in ipairs(tp) do
    if i ~= last then
      if head[p] == nil then
        head[p] = {}
      end
      head = head[p]
    else
      head[p] = data
    end
  end
end

local function check_lhs(l, opts)
  local ret = {
    key = l,
    is_num = false,
    is_str = false,
  }
  if type(l) == "number" then
    ret.is_num = true
  else
    ret.is_str = true
  end
  return ret
end

local function check_rhs(r, opts)
  local ret = {
    val = r,
    is_fun = false,
    is_tbl = false,
    id_match = false,
    numeric_keys = false,
  }

  if type(r) == "function" then
    ret.is_fun = true
    -------------------------------------------------------
  elseif type(r) == "table" then
    ret.is_tbl = true
    local num_keys = 0

    -- REFACTOR: THIS IS DOOM SPECIFIC SO IT SHOULD NOT BE IN HERE!
    if opts.type == "modules" and r.type == "module" then
      ret["is_module"] = true
    end

    for k, _ in pairs(r) do
      num_keys = num_keys + 1

      if opts.leaf_ids ~= nil then
        if vim.tbl_contains(opts.leaf_ids, k) then
          ret.id_match = true
        end
      end

      if type(k) == "number" then
        ret.numeric_keys = true
      end
    end
    ret.num_keys = num_keys
    if num_keys == 0 then
      ret.tbl_empty = true
    end
    -------------------------------------------------------
  elseif type(r) == "string" then
    ret.is_str = true
    if r == "" then
      ret.str_empty = true
    end
    -------------------------------------------------------
  elseif type(r) == "number" then
    ret.is_num = true
  end

  return ret
end

M.recurse = function(opts, tree, stack, accumulator)
  accumulator = accumulator or {}
  stack = stack or {}
  for k, v in pairs(tree) do
    local is_leaf = opts.edge(opts, check_lhs(k, opts), check_rhs(v, opts))
    logger(is_leaf, opts, stack, k, v)

    if not is_leaf then
      stack, accumulator = M.process_branch(opts, k, v, stack, accumulator)
    else
      stack, accumulator = M.process_leaf(opts, k, v, stack, accumulator)
    end
  end

  table.remove(stack, #stack)
  return accumulator
end

M.process_branch = function(opts, k, v, stack, accumulator)
    opts.branch(stack, k, v)
  -- table.insert(accumulator, ret)
  table.insert(stack, k)
  M.recurse(opts, v, stack, accumulator)
  return stack, accumulator
end

-- todo: maybe default should be to return `v`,
-- eg. if opts.leaf ... else insert v
M.process_leaf = function(opts, k, v, stack, accumulator)
  local ret = opts.leaf(stack, k, v)
  table.insert(accumulator, ret)
  return stack, accumulator
end

M.traverse_table = function(opts, tree, acc)
  opts = opts or {}
  tree = opts.tree or tree

  -- PUT ALL THESE SETUP STATEMENTS IN A METATABLE.

  -- tree to travrse (required)
  if not tree then
    -- assert tree here to make sure it is passed.
    print("TREE ERROR > tree is required")
  end

  -- OPTS.TYPE
  --     specify which leaf pattern to use.
  --     Alternatives: ( "modules" | any module_part )

  if not opts.type then
    opts.type = false
  end

  -- ACCUMULATOR
  --
  ---     if you want to continue accumulating to an already existing list, then pass this
  ---     option.
  if opts.acc then
    acc = opts.acc or acc
    -- remove acc prop
  end

  -- LOGGING CALLBACK
  ---
  ---   enable_logging: bool
  ---
  if opts.log then
  end

  -- LEAF DEFAULT CALLBACK
  --
  ---     how to process each leaf node
  ---     return appens to accumulator
  if not opts.leaf then
    opts.leaf = function(_, _, v)
      return v
    end
  end

  -- BRANCH DEFAULT CALLBACK
  --
  ---     how to process each branch node
  ---       return appens to accumulator
  if not opts.branch then
    opts.branch = function()
      return false
    end
  end

  -- OPTS.EDGE
  --
  --      table array containing predefined properties that you know identifies a leaf.
  --      Eg. doom module parts. See `core/spec.module_parts`
  if not opts.edge then
    opts.edge = function(_, _, r)
      return r.is_str
    end
  end

  return M.recurse(opts, tree, {}, acc)
end

return M
