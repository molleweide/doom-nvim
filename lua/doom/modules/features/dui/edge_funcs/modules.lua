local ax = require("doom.modules.features.dui.actions")

local function i(x)
  print(vim.inspect(x))
end

local M = {}

M.get_modules_extended = function()
  local config_path = vim.fn.stdpath("config")

  -- REFACTOR: move into utils -> get modules
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

  local all_m = get_all_module_paths()

  local prep_all_m = { doom = {}, user = {} }

  for _, p in ipairs(all_m) do
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
      list_display_props = {
        "MODULE",
        " ",
        m_origin,
        m_section,
        m_name,
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line)
          -- i(fuzzy)
          DOOM_UI_STATE.selected_module = fuzzy.value
          ax.m_edit(fuzzy.value)
        end,
        ["<C-a>"] = function(fuzzy, line)
          DOOM_UI_STATE.query = {
            type = "module",
            -- components = {}
          }
          DOOM_UI_STATE.selected_module = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = m_name, -- connect strings to make it easy to search modules. improve how?
    }
  end

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
            prep_all_m[origin][section_name][module_name].list_display_props[2] = "x"
            for k, v in pairs(doom[section_name][module_name]) do
              prep_all_m[origin][section_name][module_name][k] = v
            end
            break
          end
        end
      end
    end
  end

  -- i(prep_all_m)

  return prep_all_m
end


return M
