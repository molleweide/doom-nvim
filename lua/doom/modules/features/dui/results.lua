local ax = require("doom.modules.features.dui.actions")

local result_nodes = {}

--
-- MAIN
--

result_nodes.main_menu = function()
  local doom_menu_items = {
    {
      list_display_props = {
        { "open user config" },
      },
      mappings = {
        ["<CR>"] = function()
          vim.cmd(("e %s"):format(require("doom.core.config").source))
        end,
      },
      ordinal = "userconfig",
    },
    {
      list_display_props = {
        { "browse user settings" },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line, cb)
          DOOM_UI_STATE.query = {
            type = "settings",
          }
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "usersettings",
    },
    {
      list_display_props = {
        { "browse all modules" },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line)
          DOOM_UI_STATE.query = {
            type = "modules",
            -- origins = {},
            -- categories = {},
          }
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "modules",
    },
    {
      list_display_props = {
        { "browse all binds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "binds",
    },
    {
      list_display_props = {
        { "browse all autocmds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "autocmds",
    },
    {
      list_display_props = {
        { "browse all cmds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "cmds",
    },
    {
      list_display_props = {
        { "browse all packages" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "packages",
    },
    {
      list_display_props = {
        { "browse all jobs" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
    },
  }

  for k, v in pairs(doom_menu_items) do
    table.insert(v.list_display_props, 1, { "MAIN" })
    v["type"] = "doom_main_menu"
    -- i(v)
  end

  -- i(doom_menu_items)

  return doom_menu_items
end

--
-- MODULES
--

result_nodes.modules = function(_, _, module)
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

result_nodes.settings = function(stack, k, v)
  -- collect table_path back to setting in original table
  local pc
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, k)
  else
    pc = { k }
  end
  -- REFACTOR: concat table_path
  -- format each setting
  local pc_display = table.concat(pc, ".")
  local v_display
  if type(v) == "table" then
    local str = ""
    for _, x in pairs(v) do
      if type(x) == "table" then
        str = str .. ", " .. "subt"
      else
        str = str .. ", " .. x
      end
    end
    v_display = str -- table.concat(v, ", ")
  else
    v_display = tostring(v)
  end
  return {
    type = "module_setting",
    data = {
      table_path = pc,
      table_value = v,
    },
    list_display_props = {
      { "SETTING" },
      { pc_display },
      { v_display },
    },
    ordinal = pc_display,
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
end

--
-- PACKAGES
--

result_nodes.packages = function(_, k, v)
  local spec = v
  if type(k) == "number" then
    if type(v) == "string" then
      spec = { v }
    end
  end
  local repo_name, pkg_name = spec[1]:match("(.*)/([%w%-%.%_]*)$")
  return {
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
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
end

--
-- CONFIGS
--

result_nodes.configs = function(_, k, v)
  return {
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
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
end

--
-- CMDS
--

result_nodes.cmds = function(_, k, v)
  -- TODO: i need to attach k here as well, to table_path
  return {
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
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
end

--
-- AUTOCMDS
--

result_nodes.autocmds = function(_, k, v)
  return {
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
        -- DOOM_UI_STATE.query = {
        --   type = "settings",
        -- }
        -- DOOM_UI_STATE.next()
      end,
    },
  }
end

--
-- BINDS
--

result_nodes.binds = function(_, _, v)
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

return result_nodes
