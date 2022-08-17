local M = {}

-- TODO: REFACTOR INTO 4 sub functions.
--
-- FILTER_PROPS: origins, sections, names, enabled
--
-- FUTURE: filter levels instead -> since you might have a recursive module structure?
--
M.extend = function(filter)
  local config_path = vim.fn.stdpath("config")

  local function glob_modules(cat)
    if cat ~= "doom" and cat ~= "user" then
      return
    end
    local glob = config_path .. "/lua/" .. cat .. "/modules/*/*/"
    return vim.split(vim.fn.glob(glob), "\n")
  end

  local function get_all_module_paths()
    local glob_doom_modules = glob_modules("doom")
    local glob_user_modules = glob_modules("user")
    local all = glob_doom_modules
    for _, p in ipairs(glob_user_modules) do
      table.insert(all, p)
    end
    return all
  end

  local function add_meta_data()
    local prep_all_m = { doom = {}, user = {} }
    for _, p in ipairs(get_all_module_paths()) do
      local m_origin, m_section, m_name = p:match("/([_%w]-)/modules/([_%w]-)/([_%w]-)/$") -- capture only dirname
      -- if user is empty for now..
      if m_origin == nil then
        break
      end
      if prep_all_m[m_origin][m_section] == nil then
        prep_all_m[m_origin][m_section] = {}
      end
      prep_all_m[m_origin][m_section][m_name] = {
        type = "doom_module_single",
        enabled = false,
        name = m_name,
        section = m_section,
        origin = m_origin,
        path = p,
      }
    end
    return prep_all_m
  end

  local all_modules_base = add_meta_data()

  local function merge_with_enabled(allm)
    local prep_all_m = allm
    local enabled_modules = require("doom.core.modules").enabled_modules

    for section_name, section_modules in pairs(enabled_modules) do
      for _, module_name in pairs(section_modules) do
        local search_paths = {
          ("user.modules.%s.%s"):format(section_name, module_name),
          ("doom.modules.%s.%s"):format(section_name, module_name),
        }
        for _, path in ipairs(search_paths) do
          local origin = path:sub(1, 4)

          if prep_all_m[origin][section_name] ~= nil then
            if prep_all_m[origin][section_name][module_name] ~= nil then
              prep_all_m[origin][section_name][module_name].enabled = true
              for k, v in pairs(doom[section_name][module_name]) do
                prep_all_m[origin][section_name][module_name][k] = v
              end
              break
            end
          end
        end
      end
    end
    return prep_all_m
  end

  -- return prep_all_m
  return merge_with_enabled(all_modules_base)
end

return M
