local ax = require("doom.modules.features.dui.actions")

-- local components = {
--   main_menu = {},
--   modules = {},
-- }

-- TODO: rename this file to `components/<comp_N>.lua`
-- and then store all related customization to each component in the
-- same file SO that this file doesn't become insanely huge...

--
-- HELPERS
--

-- main_menu = surround_with("<<" , ">>", doom_menu_items)
local function surround_with_chars(t_items, search_string, start_char, end_char)
  --   - shift with s
  --   - insert with e
  --   - ???? find entry by search string -> add custom surround chars for each entry
  --
end

local function extend_entries()
  -- add the same highlighting group for all items.
end

--
-- COMPONENTS
--

local result_nodes = {}

--
-- MAIN
--
-- TODO:
--
-- return table
-- {
--  theme = string | function,
--  entry_display_config = table | function,
--  all_results = {},
--  tree_node_cb,
-- }
--
-- 0. highlights
--
--    paste neorgx into `config.lua`
--      run picker
--        understand how highlights are applied?
-- 1. center items
-- 2. theme: cursor OR center screen
-- 3. disable -> mult selection!!!
-- 4. disable `selection_caret`
-- 5. wrap menu in symbols

-- components.main_menu
result_nodes.main_menu = function()
  -- how can I test and use this?
  local main_menu = {
    theme = require("telescope.themes").get_cursor(),
    -- configurates the display for a single results entry. -> each entry can hold any number of entries
    displayer = function(ldp) -- i believe that I'll recieve the `list_display_props` for each entry here
      return {
        separator = function() end, -- menu has no sep

        -- use *nvim-treesitter-highlights* groups for colors
        items = function() end,
        -- {
        --   separator = "▏",
        --   items = {
        --     { width = 10 },
        --     { width = 20 },
        --     { width = 20 },
        --     { width = 20 },
        --     { width = 20 },
        --     { width = 20 },
        --     { remaining = true },
        --   },
        -- },
      }
    end,
    ordinal = function() end,
    entries = {},
  }

  local doom_menu_items = {
    {
      list_display_props = {
        { "OPEN USER CONFIG", "TSBoolean" },
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
        { "BROWSE USER SETTINGS", "TSError" },
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
        { "BROWSE ALL MODULES", "TSKeyword" },
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
        { "BROWSE ALL BINDS" },
      },
      mappings = {
        ["<CR>"] = function()
          DOOM_UI_STATE.query = {
            type = "MULTIPLE_MODULES",
            origins = { "doom" },
            -- sections = { "core", "features" },
            components = { "BINDS" },
          }
          -- TODO: FUZZY.VALUE.???
          DOOM_UI_STATE.selected_component = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "binds",
    },
    {
      list_display_props = {
        { "BROWSE ALL AUTOCMDS" },
      },
      mappings = {
        ["<CR>"] = function()
          DOOM_UI_STATE.query = {
            type = "MULTIPLE_MODULES",
            origins = { "doom" },
            -- sections = { "core", "features" },
            components = { "CMDS" },
          }
          -- TODO: FUZZY.VALUE.???
          DOOM_UI_STATE.selected_component = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "autocmds",
    },
    {
      list_display_props = {
        { "BROWSE ALL CMDS" },
      },
      mappings = {
        ["<CR>"] = function()
          DOOM_UI_STATE.query = {
            type = "MULTIPLE_MODULES",
            origins = { "doom" },
            -- sections = { "core", "features" },
            components = { "CMDS" },
          }
          -- TODO: FUZZY.VALUE.???
          DOOM_UI_STATE.selected_component = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "cmds",
    },
    {
      list_display_props = {
        { "BROWSE ALL PACKAGES" },
      },
      mappings = {
        ["<CR>"] = function()
          DOOM_UI_STATE.query = {
            type = "MULTIPLE_MODULES",
            origins = { "doom" },
            sections = { "core", "features" },
            components = { "PACKAGES" },
          }

          -- TODO: FUZZY.VALUE.???
          DOOM_UI_STATE.selected_component = fuzzy.value

          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "packages",
    },
    {
      list_display_props = {
        { "BROWSE ALL JOBS" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "jobs",
    },
  }

  -- -- REFACTOR: into titles for main menu
  -- for k, v in pairs(doom_menu_items) do
  --   table.insert(v.list_display_props, 1, { "MAIN" })
  --   v["type"] = "doom_main_menu"
  --   -- i(v)
  -- end

  -- i(doom_menu_items)

  return doom_menu_items
end

--
-- MODULES
--

-- result_nodes.modules = function()
--   local modules_component = {
--    themes = ,
--     displayer = ,
--     ordinal = ,
--     tree_node_cb = function(_, _, module)
--     end
--   }
-- end

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
    ["<C-b>"] = function(fuzzy, _)
      DOOM_UI_STATE.query = {
        type = "MODULE_COMPONENT",
        -- components = {}
      }
      -- TODO: FUZZY.VALUE.???
      DOOM_UI_STATE.selected_component = fuzzy.value
      DOOM_UI_STATE.next()
    end,
  }
  return module
end

--
-- SETTINGS
--

-- result_nodes.modules = function()
--   local modules_component = {
--    themes = ,
--     displayer = ,
--     ordinal = ,
--     tree_node_cb = function(_, _, module)
--     end
--   }
-- end

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

-- result_nodes.modules = function()
--   local modules_component = {
--    themes = ,
--     displayer = ,
--     ordinal = ,
--     tree_node_cb = function(_, _, module)
--     end
--   }
-- end

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
