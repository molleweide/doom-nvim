local M = {}

--- DETERMINES HOW WE RECURSE DOWN INTO SUB TABLES
---@param branch_opts
---@param a
---@param b
local function we_can_recurse(branch_opts, a, b)

  -- use rec_opts to determine what allows for recursing downwards, and what should be treaded as leaves
  --
  --   1. settings/mixed table
  --   2. key nodes w/table children containing string leaves
  --   3. anonymous sub tables
  --   4. binds table


  -- if branch_opts == "kbranch_string_leaves" then
  --   -- if type(b) == "table"
  -- end
  -- if branch_opts == "doom_binds" then
  --   -- for _, t in ipairs(nest_tree) do
  --   --   if type(t.rhs) == "table" then
  -- end

  if branch_opts == "mixed" then
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
local function get_branch_path(stack, v)
  local pc = { v }
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, v)
  end
  return pc
end


--- This is the main interface to tree
---@param tree
---@param branch_opts
---@param leaf_cb
---@param get_flattened
local function traverse_table(tree, branch_opts, branch_cb, leaf_cb, get_flattened)

  local function recurse(tree, stack, flattened)
    local flattened = flattened or {}
    local stack = stack or {}

    for k, v in pairs(tree) do

      if we_can_recurse(branch_opts, k, v) then
        table.insert(stack, k)
        -- table.insert(flattened, entry)
        -- branch_cb(pc) -- ??
        recurse(v, stack, flattened)

      else
        local pc = get_branch_path(stack, v)
        leaf_cb(pc)
        -- table.insert(flattened, entry)
      end
    end

    table.remove(stack, #stack)
    return flattened
  end

  return recurse(tree)

end








--
-- BINDS
--

-- list tree flattener. binds contain both anonymous list and potential trees.
---
---@param nest_tree / doom binds tree
---@param flattened / accumulator list of all entries
---@param bstack / keep track of recursive depth and the index chain to get back to the tree
---@return list of flattened bind entries
M.binds_flattened = function(nest_tree, flattened, bstack)
  local flattened = flattened or {}
  local sep = " | "
  local bstack = bstack or {}

  if acc == nil then

    for _, t in ipairs(nest_tree) do
      if type(t.rhs) == "table" then

        -- --
        -- -- TODO: insert an entry for each new branch here ??
        -- --
        --
        --
        --  optional flag to make a uniqe entry for each branch_step
        --
        --
        -- -- so that you can do `add_mapping_to_same_branch()` ???
        -- local entry = {
        --   type = "module_bind_branch",
        --   name = k,
        --   value = v,
        --   list_display_props = {
        --     "BIND", "", ""
        --   }
        -- }
        -- entry = table_merge(entry, t)

        table.insert(flattened, entry)

        table.insert(bstack, t.lhs)
        flattened = M.binds_flattened(t.rhs, flattened, bstack)
      else

        -- i(t)

        -- so that you can do `add_mapping_to_same_branch()` ???
        local entry = {
          type = "module_bind_leaf",
          data = t,
          list_display_props = {
            { "BIND" }, { t.lhs }, {t.name}, {t.rhs} -- {t[1], t[2], tostring(t.options)
          },
          ordinal = t.name..tostring(lhs),
          mappings = {
            ["<CR>"] = function(fuzzy,line, cb)
              i(fuzzy)
              -- doom_ui_state.query = {
              --   type = "settings",
              -- }
              -- doom_ui_state.next()
  		      end
          }
        }

        table.insert(flattened, entry)
      end
    end
  end
  table.remove(bstack, #bstack)
  return flattened
end

