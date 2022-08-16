local M = {}

--
-- PACKAGES
--

-- tree.traverse_table {
--   tree = doom.settings,
--   type = "settings",
--   leaf = function(stack, k, v)
--     local spec = v
--     if type(k) == "number" then
--       if type(v) == "string" then
--         spec = { v }
--       end
--     end
--     local repo_name, pkg_name = spec[1]:match("(.*)/([%w%-%.%_]*)$")
--     return {
--       type = "module_package",
--       data = {
--         table_path = k,
--         spec = spec,
--       },
--       list_display_props = {
--         {"PKG"},
--         {repo_name},
--         {pkg_name}
--       },
--       ordinal = repo_name .. pkg_name,
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
---@param t_packages
---@return list of flattened packages
M.packages_flattened = function(t_packages)
  if t_packages == nil then
    return
  end
  local flattened = {}

  for k, v in pairs(t_packages) do
    local spec = v
    if type(k) == "number" then
      if type(v) == "string" then
        spec = { v }
      end
    end

    local repo_name, pkg_name = spec[1]:match("(.*)/([%w%-%.%_]*)$")

    local entry = {
      type = "module_package",
      data = {
        table_path = k,
        spec = spec,
      },
      list_display_props = {
        { "PKG" },
        { repo_name },
        { pkg_name },
      },
      ordinal = repo_name .. pkg_name,
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
