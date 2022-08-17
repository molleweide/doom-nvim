local M = {}

M.get_branch = function(_, k, v)
  -- -- --
  -- -- -- TODO: insert an entry for each new branch here ??
  -- -- --
  -- --
  -- --
  -- --  optional flag to make a uniqe entry for each branch_step
  -- --
  -- --
  -- -- -- so that you can do `add_mapping_to_same_branch()` ???
  -- -- local entry = {
  -- --   type = "module_bind_branch",
  -- --   name = k,
  -- --   value = v,
  -- --   list_display_props = {
  -- --     "BIND", "", ""
  -- --   }
  -- -- }
  -- -- entry = table_merge(entry, t)
  -- table.insert(flattened, entry)
  -- table.insert(bstack, t.lhs)
  -- flattened = M.binds_flattened(t.rhs, flattened, bstack)
end

M.get_leaf = function(_, _, v)
  return {
    type = "module_bind_leaf",
    data = v,
    list_display_props = {
      { "BIND" },
      { v.lhs },
      { v.name },
      { v.rhs }, -- {v[1], v[2], tostring(v.options)
    },
    ordinal = v.name .. tostring(v.lhs),
    mappings = {
      ["<CR>"] = function()
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
  -- table.insert(flattened, entry)
end

--- nest_tree / doom binds tree
M.binds_flattened = function(nest_tree, flattened, bstack)
  flattened = flattened or {}
  bstack = bstack or {}
  -- if acc == nil then
  for _, t in ipairs(nest_tree) do
    if type(t.rhs) == "table" then
      table.insert(flattened, entry)
      table.insert(bstack, t.lhs)
      flattened = M.binds_flattened(t.rhs, flattened, bstack)
    else
      local entry = {
        type = "module_bind_leaf",
        data = t,
        list_display_props = {
          { "BIND" },
          { t.lhs },
          { t.name },
          { t.rhs }, -- {t[1], t[2], tostring(t.options)
        },
        ordinal = t.name .. tostring(t.lhs),
        mappings = {
          ["<CR>"] = function() end,
        },
      }
      table.insert(flattened, entry)
    end
  end
  -- end
  table.remove(bstack, #bstack)
  return flattened
end

return M
