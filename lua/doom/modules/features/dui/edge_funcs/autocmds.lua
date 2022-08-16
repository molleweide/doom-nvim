local M = {}
--
-- AUTOCMDS
--

-- TODO: make into a single result entry table
--
-- TODO: if type cmd / autocmd -> use same `tree-flattener` and pass `list = true` param to force only level 0 loop

---
---@param t_autocmds
---@return list of flattened entries
M.autocmds_flattened = function(t_autocmds)
  local flattened = {}
  if t_autocmds == nil then
    return
  end

  if type(t_autocmds) == "function" then
    table.insert(flattened, {
      type = "module_autocmd",
      data = {
        event = nil,
        pattern = nil,
        action = nil,
        is_func = true,
        func = t_autocmds,
      },
      ordinal = "autocmd_func",
      list_display_props = {
        { "AUTOCMD" },
        { "isfunc" },
        { tostring(t_autocmds) },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line, cb)
          i(fuzzy)
          -- DOOM_UI_STATE.query = {
          --   type = "settings",
          -- }
          -- DOOM_UI_STATE.next()
        end,
      },
    })
  else
    for k, v in pairs(t_autocmds) do
      table.insert(flattened, {
        type = "module_autocmd",
        data = {
          event = v[1],
          pattern = v[2],
          action = v[3],
        },
        ordinal = v[1] .. v[2],
        list_display_props = {
          { "AUTOCMD" },
          { v[1] },
          { v[2] },
          { tostring(v[3]) },
        },
        mappings = {
          ["<CR>"] = function(fuzzy, line, cb)
            i(fuzzy)
            -- DOOM_UI_STATE.query = {
            --   type = "settings",
            -- }
            -- DOOM_UI_STATE.next()
          end,
        },
      })
    end
  end

  return flattened
end


return M
