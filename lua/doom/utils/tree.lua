local M = {}

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
    for _ in ipairs(stack) do
      a = a .. "-"
    end
    return a .. ">"
  end


--- DETERMINES HOW WE RECURSE DOWN INTO SUB TABLES
---@param branch_opts
---@param a
---@param b
local function we_can_recurse(opts, a, b, stack)

  -- use rec_opts to determine what allows for recursing downwards, and what should be treaded as leaves
  --
  --   1. settings/mixed table
  --   2. key nodes w/table children containing string leaves
  --   3. anonymous sub tables
  --   4. binds table

  if opts.type == "modules"  then
    -- print(a, b)
    if type(b) == "table"  then

      if opts.stop_at == "modules" then
        -- print(ind(stack), a, b)
        for k, v in pairs(b) do
          if vim.tbl_contains(MODULE_PARTS, k) then
            -- print(":", k, type(k), v, type(v))
            return 1
          else
            return 0
          end
        end
      else
        return 0
      end


    else
      return 1
    end
  end

  -- if opts.type == "binds" then
  --   -- for _, t in ipairs(nest_tree) do
  --   --   if type(t.rhs) == "table" then
  -- end

  if opts.type == "settings" then
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
---    leaf
---@return accumulator
M.traverse_table = function(opts)

  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      -- if #stack == 0 then
      --   print(ind() .. ">" , k, v, "------------------------------------------------------------------")
      -- end

      -- if opts.stop_at == "modules" then
      --   print(ind() .. ">" , k, v)
      -- end

      local wc = we_can_recurse(opts, k, v, stack)

      if wc == 0 then
        -- branch

        table.insert(stack, k)
        recurse(v, stack, accumulator)

      elseif wc == 1 then
          -- print(k,v)
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
