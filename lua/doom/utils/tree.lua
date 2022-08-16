local M = {}

-- TODO: IN LOGGER FOR EACH NODE LOG THE EDGE COMPUTE DATA.

local log = {
  sep = "*---",
  use = false,
  leaf = false,
  branch = false,
  edge = false,
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
-- use opts.log_prefix??
local function logger(pre, opts, stack, k, v)
  if opts.log then
    print("|[", pre, "]", compute_indentation(stack), k, v)
  end
end

--- Concatenates the stack with the leaf node.
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

local function check_lhs(l)
  return {
    key = l,
    is_num = type(l) == "number",
    is_str = type(l) == "string",
  }
end

local function check_rhs(r, opts)
  local t = type(r)
  local ret = {
    val = r,
    is_fun = t == "function",
    is_tbl = t == "table",
    is_str = t == "string",
    is_num = t == "number",
    str_empty = r == "",
    id_match = false,
    numeric_keys = false,
    num_keys = nil,
  }
  if ret.is_tbl then
    local num_keys = 0
    for k, _ in pairs(r) do
      num_keys = num_keys + 1
      if opts.leaf_ids then
        if vim.tbl_contains(opts.leaf_ids, k) then
          ret.id_match = true
        end
      end
      ret.numeric_keys = type(k) == "number"
    end
    ret.num_keys = num_keys
    ret.tbl_empty = num_keys == 0
  end
  return ret
end

M.recurse = function(opts, tree, stack, accumulator)
  accumulator = accumulator or {}
  stack = stack or {}
  for k, v in pairs(tree) do
    local is_leaf = opts.edge(opts, check_lhs(k), check_rhs(v, opts))
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

  if not tree then
    -- assert tree here to make sure it is passed.
    print("TREE ERROR > tree is required")
  end

  -- OPTS.TYPE
  --     specify which leaf pattern to use.
  --     Alternatives: ( "modules" | any module_part )

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

  opts.leaf_ids = opts.leaf_ids or false

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
