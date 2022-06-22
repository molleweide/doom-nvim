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
local function is_edge(opts, a, b, stack)
  local edge = false

  if opts.type == "modules"  then
    if type(b) == "table"  then
      if opts.stop_at == "modules" then
        for k, v in pairs(b) do
          if vim.tbl_contains(MODULE_PARTS, k) then
            edge = true
          end
        end
      end
    else
      edge = true
    end

  elseif opts.type == "settings" then
    if type(a) == "number" then
      edge = true
    end
    if type(b) ~= "table" then
      edge = true
    end
    local cnt = 0
    for k, v in pairs(b) do
      cnt = cnt + 1
      if type(k) == "number" then
        -- print("IS_SUB; sub table has number",  a)
        edge = true
      end
    end
    if cnt == 0 then
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
---@return accumulator
M.traverse_table = function(opts, logtree)
  local opts = opts or {}

  local function recurse(tree, stack, accumulator)

    local accumulator = accumulator or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      if logtree then
        print("LOG TREE")
        log_tree(opts, stack, k, v)
      end

      if not is_edge(opts, k, v, stack) then

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
