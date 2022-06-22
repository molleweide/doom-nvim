local M = {}

--- DETERMINES HOW WE RECURSE DOWN INTO SUB TABLES
---@param branch_opts
---@param a
---@param b
local function we_can_recurse(node_type, a, b)

  -- use rec_opts to determine what allows for recursing downwards, and what should be treaded as leaves
  --
  --   1. settings/mixed table
  --   2. key nodes w/table children containing string leaves
  --   3. anonymous sub tables
  --   4. binds table

  if node_type == "modules"  then
    if type(b) == "table" then
      return true
    else
      return false
    end
  end

  -- if node_type == "binds" then
  --   -- for _, t in ipairs(nest_tree) do
  --   --   if type(t.rhs) == "table" then
  -- end

  if node_type == "settings" then
    if type(a) == "number" then
      return false
    end
    if type(b) ~= "table" then
      -- print(":: number:", b)
      return false
    end
    local cnt = 0
    for k, v in pairs(b) do
      cnt = cnt + 1
      if type(k) == "number" then
        -- print("IS_SUB; sub table has number",  a)
        return false
      end
    end
    if cnt == 0 then
      return false
    end
    return true
  end

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


--- This is the main interface to tree
---
---@param opts
---   tree (required)
---    type (default: )
---    leaf
---@return accumulator
M.traverse_table = function(opts)

  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      if we_can_recurse(opts.type, k, v) then
        table.insert(stack, k)
        recurse(v, stack, accumulator)

      else
        -- local pc = flatten_stack(stack, v)
        local acc = opts.leaf(stack, k, v)
        table.insert(accumulator, acc)

      end
    end

    table.remove(stack, #stack)
    return accumulator
  end

  return recurse(opts.tree)

end

return M
