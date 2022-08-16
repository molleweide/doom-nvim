local M = {}
--
-- CONFIGS
--

-- tree.traverse_table {
--   tree = doom.settings,
--   type = "settings",
--   leaf = function(stack, k, v)
--     return {
--       type = "module_config",
--       data = {
--         table_path = k,
--         table_value = v,
--       },
--       list_display_props = {
--         {"CFG"},
--         {tostring(k)},
--         {tostring(v)}
--       },
--       ordinal = tostring(k),
--       mappings = {
--         ["<CR>"] = function(fuzzy,line, cb)
--           i(fuzzy)
--           -- DOOM_UI_STATE.query = {
--           --   type = "settings",
--           -- }
--           -- DOOM_UI_STATE.next()
--   		  end
--       }
--     }
--   end
-- }

---
---@param t_configs
---@return list of flattened entries
M.configs_flattened = function(t_configs)
  local flattened = {}
  for k, v in pairs(t_configs) do
    local entry = {
      type = "module_config",
      data = {
        table_path = k,
        table_value = v,
      },
      list_display_props = {
        { "CFG" },
        { tostring(k) },
        { tostring(v) },
      },
      ordinal = tostring(k),
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

  return flattened
end

return M
