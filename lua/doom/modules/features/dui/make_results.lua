local ut = require("doom.modules.features.dui.utils")
local tree = require("doom.utils.tree")

local res_modules = require("doom.modules.features.dui.edge_funcs.modules")
local res_main = require("doom.modules.features.dui.edge_funcs.main")
local res_settings = require("doom.modules.features.dui.edge_funcs.settings")

local M = {}

M.get_results_for_query = function()
  local results = {}

  if DOOM_UI_STATE.query.type == "main_menu" then
    for _, entry in ipairs(res_main.main_menu_flattened()) do
      table.insert(results, entry)
    end
    -- results = tree.traverse_table({
    --   tree = doom.settings,
    --   -- type = "settings",
    --   leaf = res_settings.mr_settings,
    --   edge = function(_, l, r)
    --     return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
    --   end,
    -- })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "settings" then
    results = tree.traverse_table({
      tree = doom.settings,
      -- type = "settings",
      leaf = res_settings.mr_settings,
      edge = function(_, l, r)
        return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
      end,
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "modules" then
    results = tree.traverse_table({
      tree = res_modules.get_modules_extended(),
      -- type = "modules",
      leaf_ids = require("doom.core.spec").module_components,
      edge = function(_, _, r)
        return r.is_module or (r.is_tbl and r.id_match)
      end,
      -- log = true,
    })
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "module" then
    -- TODO: HOW IS THIS SELECTED?
    for mk, m_part in pairs(DOOM_UI_STATE.selected_module) do
      for _, qp in ipairs(DOOM_UI_STATE.query.parts or require("doom.core.spec").module_components) do
        if mk == qp then
          for _, entry in pairs(M[mk .. "_flattened"](m_part)) do
            table.insert(results, entry)
          end
        end
      end
    end
    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
  elseif DOOM_UI_STATE.query.type == "component" then
  elseif DOOM_UI_STATE.query.type == "all" then
  end

  return results
end

return M
