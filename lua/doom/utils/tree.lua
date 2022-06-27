local M = {}

-- TODO: use table `log.use = true` instead
local LOG_SEP = "*---"
local LOG = true
local LOG_TYPE = "modules"

-- TODO: move to "core/spec.lua"
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
local function ind(stack)
  local a = ""
  for i=0, #stack do
    a = a .. LOG_SEP
  end
  return a .. ">"
end

-- THE FOLLOWING FUNCTIONS ANALYZE EACH NODE AND RETURN TABLES WITH INFORMATION
-- MAKING IT EASY FOR USER TO DEFINE EDGE CASES.

-- Helper tool for debuggin the traversal
--
--
local function logger(pre, opts, stack, k, v)
  if LOG and opts.type == LOG_TYPE then
    -- print("#################################")
    print(opts.type, "|[", pre, "]", ind(stack), k, v)
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
        ret["id_match"] = true
      end

      if type(k) == "number" then
        ret["numeric_keys"] = true
      end

    end
    ret["num_keys"] = num_keys

  elseif type(r) == "string" then
    -- print("string", vim.inspect(r))
    ret["is_str"] = true

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

  if opts.type == "modules" and rhs.is_tbl and rhs.id_match then
    leaf = true
  end

  if opts.type == "settings"
    and (lhs.is_num or (not rhs.is_tbl) or rhs.numeric_keys or rhs.num_keys == 0) then
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

--- THIS IS THE MAIN INTERFACE TO TREE
---
--- 1. opts table
--- 2.
---
--- TODO: smart defaults. look at telescope.nvim
---
---@param opts
---   tree (required)
---     tree you wish to traverse.
---
---   type
---     specify which leaf pattern to use.
---     Alternatives: ( "modules" | any module_part )
---
---   enable_logging: bool
---
---   fn_log_cb
---     pass a custom log function
---
---   fn_leaf_cb
---     how to process each leaf node
---     return appens to accumulator
--
---   fn_branch_cb
---     how to process each branch node
---       return appens to accumulator
--
---   leaf_ids
--      table array containing predefined properties that you know identifies a leaf.
--      Eg. doom module parts. See `core/spec.module_parts`
--
---@return accumulator. Whatever you return in branch/leaf callbacks will be appended
--        to the accumulator
M.traverse_table = function(opts)
  local opts = opts or {}

  -- TODO: manage default values in the same manner as telescope.nvim source.

  -- Implements the recursive skeleton for traversing tables.
  --
  -- 1. Takes a table.
  -- 2. keeps track of the stack.
  -- 3. Gives you an accumulator that can be used in order to flatten or accumulate some
  --    specific data that you want to collect when traversing.
  --
  --    Use the `opts.branch` and `opts.leaf` callbacks to process each node however you like.
  --    You can see how this is used in `core/modules`
  --
  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      local ret = branch_or_leaf(opts, k, v, stack)

      logger(ret.is_leaf, opts, stack, k, v)

      if not ret.is_leaf then

        -- PROCESS BRANCH --

        if opts.branch then
          ret = opts.branch(stack, k, v)
          -- table.insert(accumulator, ret)
        end

        table.insert(stack, k)
        recurse(v, stack, accumulator)

      else

        -- PROCESS LEAF --

          if opts.leaf then
            ret = opts.leaf(stack, k, v)
            table.insert(accumulator, ret)
          end

      end
    end

    table.remove(stack, #stack)
    return accumulator
  end

  return recurse(opts.tree)

end

return M
