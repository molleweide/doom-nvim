local M = {}

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
end

return M
