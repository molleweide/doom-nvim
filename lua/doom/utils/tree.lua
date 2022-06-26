local M = {}

-- todo: move to "core/spec.lua"
local MODULE_PARTS = {
    "settings",
    "packages",
    "configs",
    "binds",
    "cmds",
    "autocmds",
}

--- Helper for logging the tree,
---@param stack
---@return -- * * ... * >
local function ind(stack)
  local a = ""
  for _ in ipairs(stack) do
    a = a .. "* "
  end
  return a .. ">"
end

local function check_lhs(l)
  local l = {}
  if type(l) == "number" then
    l["is_num"] = true
  else
    l["is_str"] = true
  end
  return l
end

local function check_rhs(r, leaf_ids)
  local r = {}
  if type(r) == "function" then
    r["is_fun"] = true
  elseif type(r) == "table"  then
    r["is_tbl"] = true

    for k, v in pairs(r) do
      num_keys = num_keys + 1

      -- replace this with `leaf_ids`
      -- defaults to always check for `doom.spec.module_parts`
      -- todo: `core/spec.lua`
      --
      -- if not leaf_ids use MODULE_PARTS
      if vim.tbl_contains(MODULE_PARTS, k) then
        r["id_match"] = true
      end

      if type(k) == "number" then
        r["numeric_keys"] = true
      end

    end
    r["num_keys"] = num_keys
  elseif type(r) == "string" then
    r["is_str"] = true
  end

  return r
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
local function is_edge(opts, a, b, stack, leaf_ids)
  local edge = false
  local lhs = check_lhs(a)
  local rhs = check_rhs(b, leaf_ids)


  -- TODO: pass table of edge definitions so that this can be completely
  -- dynamic

  if opts.type == "modules"  then
    if rhs.is_tbl and leaf.id_match or rhs.is_str then
      edge = true
    end

  elseif opts.type == "settings" then
    if lhs.is_num or (not rhs.is_tbl) or rhs.numeric_keys or rhs.num_keys == 0 then
      edge = true
    end

  end

  -- if opts.type == "binds" then
  --   -- for _, t in ipairs(nest_tree) do
  --   --   if type(t.rhs) == "table" then
  -- end

  return edge
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

local function log_tree(opts, stack, k, v)

  -- if #stack == 0 then
  --   print(ind() .. ">" , k, v, "------------------------------------------------------------------")
  -- end

  -- if opts.stop_at == "modules" then
    print(ind() .. ">" , k, v)
  -- end

end


--- This is the main interface to tree
---
---@param opts
---   tree (required)
---    type (default: )
---    leaf
---@param logtree,
---@param leaf_ids table array of identifiers that indicate that a rhs table is
---       a leaf and not a new sub table to recurse into.
---@return accumulator
M.traverse_table = function(opts, logtree, leaf_ids)
  local opts = opts or {}

  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      if logtree then
        print("LOG TREE")
        log_tree(opts, stack, k, v)
      end

      if not is_edge(opts, k, v, stack, leaf_ids) then

          -- local ret
          -- if opts.branch then
          --   ret = opts.branch(stack, k, v)
          -- end

        table.insert(stack, k)
        recurse(v, stack, accumulator)

      else
          -- print(k,v)

          local ret
          if opts.leaf then
            ret = opts.leaf(stack, k, v)
          end

          table.insert(accumulator, ret)

      end
    end

    table.remove(stack, #stack)
    return accumulator
  end

  return recurse(opts.tree)

end

return M
