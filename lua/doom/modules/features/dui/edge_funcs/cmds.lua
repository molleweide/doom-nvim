local M = {}
--
-- CMDS
--

-- tree.traverse_table {
--   tree = doom.settings,
--   type = "settings",
--   leaf = function(stack, k, v)
--     -- i need to attach k here as well, to table_path
--     local entry = {
--       type = "module_cmd",
--       data = {
--         name = v[1],
--         cmd = v[2],
--       },
--       ordinal = v[1],
--       list_display_props = {
--         {"CMD"},
--         {tostring(v[1])},
--         {tostring(v[2])}
--       },
--       mappings = {
--         ["<CR>"] = function(fuzzy,line, cb)
--           i(fuzzy)
--           -- doom_ui_state.query = {
--           --   type = "settings",
--           -- }
--           -- doom_ui_state.next()
--   		  end
--       }
--     }
--   end
-- }

---
---@param t_cmds
---@return list of flattened entries
M.cmds_flattened = function(t_cmds)
  local flattened = {}

  if t_cmds == nil then
    return
  end

  for k, v in pairs(t_cmds) do
    -- i need to attach k here as well, to table_path

    local entry = {
      type = "module_cmd",
      data = {
        name = v[1],
        cmd = v[2],
      },
      ordinal = v[1],
      list_display_props = {
        { "CMD" },
        { tostring(v[1]) },
        { tostring(v[2]) },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line, cb)
          i(fuzzy)
          -- doom_ui_state.query = {
          --   type = "settings",
          -- }
          -- doom_ui_state.next()
        end,
      },
    }

    table.insert(flattened, entry)
  end

  return flattened
end


return M
