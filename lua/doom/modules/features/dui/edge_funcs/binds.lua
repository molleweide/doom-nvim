local M = {}
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
  flattened = flattened or {}
  local sep = " | "
  bstack = bstack or {}
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
            { "BIND" },
            { t.lhs },
            { t.name },
            { t.rhs }, -- {t[1], t[2], tostring(t.options)
          },
          ordinal = t.name .. tostring(lhs),
          mappings = {
            ["<CR>"] = function(fuzzy, line, cb)
              i(fuzzy)
              -- DOOM_UI_STATE.query = {
              --   type = "settings",
              -- }
              -- DOOM_UI_STATE.next()
            end,
          },
        }

        table.insert(flattened, entry)
      end
    end
  end
  table.remove(bstack, #bstack)
  return flattened
end

return M
