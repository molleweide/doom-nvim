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

-- Collect data from LEFT hand side of a table node
--
-- @return table of relevant data for building recursive pattern specs
local function check_lhs(l, opts)
  local ret = {}
  if type(l) == "number" then
    ret["is_num"] = true
  else
    ret["is_str"] = true
  end
  return ret
end

-- Collect data from RIGHT hand side of a table node
--
-- @return table of relevant data for building recursive pattern specs
local function check_rhs(r, opts)
  local ret = {}

  if type(r) == "function" then
    ret["is_fun"] = true
  elseif type(r) == "table" then
    ret["is_tbl"] = true

    local num_keys = 0

    if opts.type == "modules" and r.type == "module" then
      ret["is_module"] = true
    end

    for k, v in pairs(r) do
      num_keys = num_keys + 1

      -- replace this with `leaf_ids`
      -- defaults to always check for `doom.spec.module_parts`
      -- TODO: `core/spec.lua`
      --
      -- if not opts.leaf_ids use MODULE_PARTS
      --
      -- TODO: pass as argument
      if vim.tbl_contains(MODULE_PARTS, k) then
        -- todo: AND type == `modules` so that we don't accidentally use this filter.
        ret["id_match"] = true
      end

      if type(k) == "number" then
        ret["numeric_keys"] = true
      end
    end
    ret["num_keys"] = num_keys
    if num_keys == 0 then
      ret["tbl_empty"] = true
    end
  elseif type(r) == "string" then
    ret["is_str"] = true
    if r == "" then
      ret["str_empty"] = true
    end
  elseif type(r) == "number" then
    ret["is_num"] = true
  end

  return ret
end

-- DETERMINES HOW WE RECURSE DOWN INTO SUB TABLES
--
-- Currently this function contains a set of hardcoded definitions so that this function can be
-- used for everything (load config, modules, service/keymap, dui, etc.), but the idea is to make this a bit tighter
-- so that you can specify with minimal effort the recursive definition for each case easilly.
--
-- 1. The aim of this util is to be very general
-- 2. Allow for quickly specifying recursive table patterns.
-- 3. You do this by writing how leaf nodes should be identified.
-- 4. Two methods for doing so:
--    a. hard code: add a new if-statement and check for a specific opts.type and write your leaf pattern.
--    b. pass variable: pass an opts.leaf_pattern prop that specifies your leaf pattern.
--
local function branch_or_leaf(opts, node_lhs, node_rhs, stack)
  local leaf = false
  local lhs = check_lhs(node_lhs, opts)
  local rhs = check_rhs(node_rhs, opts)

  -- TODO: pass variable filters as func param each of the following cases should be refactore into an argument for the function

  if opts.type == "load_config" and rhs.is_str then
    leaf = true
  end

  if rhs.is_module or (opts.type == "modules" and rhs.is_tbl and rhs.id_match) then
    leaf = true
  end

  if
    opts.type == "settings"
    and (lhs.is_num or not rhs.is_tbl or rhs.numeric_keys or rhs.tbl_empty)
  then
    leaf = true
  end

  -- TODO: binds
  -- if opts.type == "binds" then
  --   -- for _, t in ipairs(nest_tree) do
  --   --   if type(t.rhs) == "table" then
  -- end

  return {
    is_leaf = leaf,
    lhs = lhs,
    rhs = rhs,
  }
end


M.recurse = function(opts, tree, stack, accumulator)
  accumulator = accumulator or {}
  stack = stack or {}

  for k, v in pairs(tree) do
    local ret = branch_or_leaf(opts, k, v, stack)

    logger(ret.is_leaf, opts, stack, k, v)

    if not ret.is_leaf then
      stack, accumulator = M.process_branch(opts, k, v, stack, accumulator)
    else
      stack, accumulator = M.process_leaf(opts, k, v, stack, accumulator, ret)
    end
  end

  table.remove(stack, #stack)
  return accumulator
end

M.process_branch = function(opts, k, v, stack, accumulator)
  if opts.branch then
    opts.branch(stack, k, v)
    -- table.insert(accumulator, ret)
  end
  table.insert(stack, k)
  M.recurse(opts, v, stack, accumulator)
  return stack, accumulator
end

-- todo: maybe default should be to return `v`,
-- eg. if opts.leaf ... else insert v
M.process_leaf = function(opts, k, v, stack, accumulator, ret)
  if opts.leaf then
    ret = opts.leaf(stack, k, v)
    table.insert(accumulator, ret)
  end
  return stack, accumulator
end

M.traverse_table = function(opts, tree, acc)
  opts = opts or {}

  -- PUT ALL THESE SETUP STATEMENTS IN A METATABLE.

  -- tree to travrse (required)
  if opts.tree then
    tree = opts.tree or tree
    -- remove tree prop
  end

  --     specify which leaf pattern to use.
  --     Alternatives: ( "modules" | any module_part )
  if opts.type then
  end

  -- accumulator
  --
  ---     if you want to continue accumulating to an already existing list, then pass this
  ---     option.
  if opts.acc then
    acc = opts.acc or acc
    -- remove acc prop
  end

  ---
  ---   enable_logging: bool
  ---

  -- logging callback
  if opts.log then
  end

  -- leaf callback
  ---     how to process each leaf node
  ---     return appens to accumulator
  if opts.leaf then
  end

  -- branch callback
  ---     how to process each branch node
  ---       return appens to accumulator
  if opts.branch then
  end

  --      table array containing predefined properties that you know identifies a leaf.
  --      Eg. doom module parts. See `core/spec.module_parts`
  if opts.leaf_ids then
  end

  return M.recurse(opts, tree, {}, acc)
end

return M
