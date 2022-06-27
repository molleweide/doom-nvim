local M = {}

local LOG_SEP = "*---"
local LOG = true
local LOG_TYPE = "modules"

-- todo: move to "core/spec.lua"
local MODULE_PARTS = {
    "settings",
    "packages",
    "configs",
    "binds",
    "cmds",
    "autocmds",
}

local function ind(stack)
  local a = ""
  for i=0, #stack do
    a = a .. LOG_SEP
  end
  return a .. ">"
end

local function logger(pre, opts, stack, k, v)
  if LOG and opts.type == LOG_TYPE then
    -- print("#################################")
    print(opts.type, "|[", pre, "]", ind(stack), k, v)
  end
end

local function check_lhs(l)
  local ret = {}
  if type(l) == "number" then
    ret["is_num"] = true
  else
    ret["is_str"] = true
  end
  return ret
end

local function check_rhs(r, leaf_ids)
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
      -- todo: `core/spec.lua`
      --
      -- if not leaf_ids use MODULE_PARTS
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

--- DETERMINES HOW WE RECURSE DOWN INTO SUB TABLES
--
--  rename: a,b -> ( lhs, rhs )
--
--  - Default: treat tables w/numeric keys as leaf nodes
--
-- - merge the (b) table checks into one helper function
-- that returns all relevant state information
--
--
---@param branch_opts
---@param a
---@param b
local function branch_or_leaf(opts, a, b, stack, leaf_ids)
  local leaf = false
  local lhs = check_lhs(a)
  local rhs = check_rhs(b, leaf_ids)

  -- TODO: pass table of edge definitions so that this can be completely
  -- dynamic

  if opts.type == "load_config"  then
    if rhs.is_str then
      leaf = true
    end

  elseif opts.type == "modules"  then
    if rhs.is_tbl and rhs.id_match then
      leaf = true
    end


  elseif opts.type == "settings" then
    if lhs.is_num or (not rhs.is_tbl) or rhs.numeric_keys or rhs.num_keys == 0 then
      leaf = true
    end

  end

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


--- returns the full path to leaf as an array
---@param stack
---@param v
---@return
local function flatten_stack(stack, v)
  local pc = { v }
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, v)
  end
  return pc
end

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

--- This is the main interface to tree
---
---@param opts
---   tree (required)
---    type (default: )
---    fn_leaf_cb
---    fn_branch_cb
---   fn_log_cb
---@param logtree,
---@param leaf_ids table array of identifiers that indicate that a rhs table is
---       a leaf and not a new sub table to recurse into.
---@return accumulator
M.traverse_table = function(opts, logtree, leaf_ids)
  local opts = opts or {}

  -- TODO: manage default values in the same manner as telescope.nvim source.

  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}


    for k, v in pairs(tree) do

      local ret = branch_or_leaf(opts, k, v, stack, leaf_ids)

      logger(ret.is_leaf, opts, stack, k, v)

      if not ret.is_leaf then

        if opts.branch then
          ret = opts.branch(stack, k, v)
          -- table.insert(accumulator, ret)
        end

        table.insert(stack, k)
        recurse(v, stack, accumulator)

      else

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
