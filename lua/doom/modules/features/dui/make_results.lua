local ax = require("doom.modules.features.dui.actions")
local ut = require("doom.modules.features.dui.utils")
local tree = require("doom.utils.tree")
local extmod = require("doom.utils.extended_modules")

local res_main = require("doom.modules.features.dui.edge_funcs.main")
local res_settings = require("doom.modules.features.dui.edge_funcs.settings")

local function i(x)
  print(vim.inspect(x))
end

local M = {}

local MODULE_ORIGINS = {
  "user",
  "doom",
}

local MODULE_CATEGORIES = {
  "core",
  "features",
  "langs",
  "themes",
}

local MODULE_PARTS = {
  "settings",
  "packages",
  "configs",
  "binds",
  "cmds",
  "autocmds",
}

-- TODO: filters -> investigate

--- Gets the results list for the given query made by user. Currently this is
--- done with a global ui state query, so you can't really pass params to func
--- but maybe passing params would be better, I dunno.
---@param type
---@param components
---@return merged list of all entries prepared for telescope.
M.get_results_for_query = function(type, components)
  local results = {}

  -- inspect_ui_state()

  if doom_ui_state.query.type == "main_menu" then
    for _, entry in ipairs(res_main.main_menu_flattened()) do
      table.insert(results, entry)
    end
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif doom_ui_state.query.type == "settings" then
    results = tree.traverse_table({
      tree = doom.settings,
      type = "settings",
      leaf = res_settings.mr_settings,
      acc = results,
      edge = function(o, l, r)
        return o.type == "settings" and (l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty)
      end,
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif doom_ui_state.query.type == "modules" then
    results = tree.traverse_table({
      tree = extmod.get_modules_extended(),
      type = "modules",
      leaf = function(_, k, v)
        return v
      end,
      acc = results,
      edge = function(o, l, r)
        return r.is_module or (o.type == "modules" and r.is_tbl and r.id_match)
      end,
      -- log = true,
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif doom_ui_state.query.type == "module" then
    -- TODO: HOW IS THIS SELECTED?
    for mk, m_part in pairs(doom_ui_state.selected_module) do
      for _, qp in ipairs(doom_ui_state.query.parts or MODULE_PARTS) do
        if mk == qp then
          for _, entry in pairs(M[mk .. "_flattened"](m_part)) do
            table.insert(results, entry)
          end
        end
      end
    end
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif doom_ui_state.query.type == "component" then
  elseif doom_ui_state.query.type == "all" then
  end

  return results
end

return M
