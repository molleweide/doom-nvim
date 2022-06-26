local M = {}

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
  local l_num = false
  local l_fun = false
  local l_str = false
  if type(l) == "number" then
    l_num = true
  else
    l_str = true
  end
  return l_str, l_num
end

local function check_rhs(r, leaf_ids)
  local num_keys = 0
  local r_fun = false
  local is_table = false
  local is_mod = false
  local has_numeric_key = false

  -- if sub table collect all relevant data about sub key/val pairs
  if type(r) == "function" then
    r_fun = true
  elseif type(r) == "table"  then
    is_table = true

    for k, v in pairs(r) do
      num_keys = num_keys + 1

      -- replace this with `leaf_ids`
      -- defaults to always check for `doom.spec.module_parts`
      -- todo: `core/spec.lua`
      --
      -- if not leaf_ids use MODULE_PARTS
      if vim.tbl_contains(MODULE_PARTS, k) then
        is_mod = true
      end

      if type(k) == "number" then
        has_numeric_keys = true
      end

    end
  end

  return is_table, num_keys, has_numeric_key, is_mod, r_fun
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

  local lhs_is_str, lhs_is_num = check_lhs(a)
  local rhs_is_tbl, rhs_key_cnt, rhs_has_numeric, cur_node_is_doom_module, rhs_is_fun = check_rhs(b, leaf_ids)

  if opts.type == "modules"  then

    -- TODO: use this snippet instead
    -- if lhs_is_num or (not rhs_is_num) or rhs_has_numeric or rhs_key_cnt == 0 then
    --   edge = true
    -- end

    if rhs_is_tbl and cur_node_is_doom_module then
      edge = true
    end

    if type(b) == "table"  then

      -- sub table AND contains any of the `special` doom module keywords, treate as leaf and return
      if opts.stop_at == "modules" then
        -- REFACTOR: table_is_module(t)
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

    -- TODO: use this snippet instead
    -- if lhs_is_num or (not rhs_is_num) or rhs_has_numeric or rhs_key_cnt == 0 then
    --   edge = true
    -- end

    -- Key IS a number
    -- Value could be a table, which would mean that the whole sub table is treated as a leaf node
    -- REFACTOR: is_number()
    if type(a) == "number" then
      edge = true
    end

    -- Value is NOT table
    -- REFACTOR: is_table()
    if type(b) ~= "table" then
      edge = true
    end

    -- Value is table
    -- Loop val and check if sub table is empty, or other pre-defined states
    local cnt = 0
    -- REFACTOR: has_numeric_keys(t)
    for k, v in pairs(b) do
      cnt = cnt + 1

      -- If a sub table contains a numeric key -> treat the whole table as a leaf, eg. in the case of
      -- options/settings tables, if a table contains a numeric/anonymous key then default would be
      -- to treate the whole table as a single `settings` entry (eg. nvim-cmp abbreviations: Snp, Buf, etc.)
      -- This has to be explored further so that docs can be written more clearly. I am not sure yet.
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
