local ax = require("doom.modules.features.dui.actions")

local M = {}

M.get_results = function(_, _, module)
  module["ordinal"] = module.name -- connect strings to make it easy to search modules. improve how?

  module["list_display_props"] = {
    "MODULE",
    module.enabled and "x" or " ",
    module.origin,
    module.section,
    module.name,
  }

  module["mappings"] = {
    ["<CR>"] = function(fuzzy, _)
      -- i(fuzzy)
      DOOM_UI_STATE.selected_module = fuzzy.value
      ax.m_edit(fuzzy.value)
    end,
    ["<C-a>"] = function(fuzzy, _)
      DOOM_UI_STATE.query = {
        type = "module",
        -- components = {}
      }
      DOOM_UI_STATE.selected_module = fuzzy.value
      DOOM_UI_STATE.next()
    end,
  }

  return module
end

return M
