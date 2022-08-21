local utils = require("doom.utils")
local ax = require("doom.modules.features.dui.actions")

-- TODO:
--
--  - NOTE: SEPARATOR HIGHLIGHTS DOES NOT WORK
--
--  - >>>>> fix `modules` query from main menu.
--  - add opts to modules.
--  - custom color per each origin/section
--
--  - add highlights to `settings`
--  - add opts to settings.
--
--  - create default styles.
--
--  - REFACTOR: THE `EXTEND` FUNCTION SO THAT IT DOESN'T LOOK LIKE SHIT.
--
--
--  5.
--  6. Default separator highlighting
--  7. try highlighting with hex colors.
--
-- NOTE: would entry.displayer = self.packages.displayer work?!?!

--
-- HELPERS
--

-- todo: rename create entry and add metatable with the `surround char` and other features built into it
--
-- will this work with single-entry tables, eg. `packages` template below?
--
--
-- TODO: move into utils
local function entries_surround_with(start_char, end_char, t_entries, search_string)
  for i, _ in pairs(t_entries) do
    table.insert(t_entries[i].items, 1, start_char)
    table.insert(t_entries[i].items, end_char)
  end
  return t_entries
end

-- if single prop > insert prop into value.
-- if two then write value[key] = prop
--
-- items / key
-- items / key / prop
local function add_opts_to_each_sub_table(items, a, b)
  for key, value in pairs(items) do
    if b then
      value[a] = b
    else
      table.insert(value, a)
    end
  end
end

-- if you are building a menu and you want to apply props to multiple entries.
-- Then wrap the entries in this function and supply your args.
--
-- metatable -> component.extend_with()
--
--
-- RENAME: add new entries
--
-- if only two args apply the options globally to all entries on the left. otherwise apply them to the new entries,
-- and then insert these into the main table.
--
local function extend_entries_list(t_to_extend, opts, input_entries)
  -- if not t and t not == table -> return

  -- if single string -> then just add the highlight group

  -- CAN I DO THIS WITH VIM.TBL_EXTEND()????
  if input_entries then
    -- We should never arrive here if we pass the `items` table.
    -- Only for the `entries` list
    for k, v in ipairs(input_entries) do
      for o, opt in pairs(opts) do
        if o == "hl" then
          add_opts_to_each_sub_table(v.items, opts.hl)
        else
        end
      end
      table.insert(t_to_extend, v)
    end
  else
    for k, v in ipairs(t_to_extend) do
      for o, opt in pairs(opts) do
        if o == "hl" then
          -- table.insert(v.items, opts.hl)
          if v.items then
            add_opts_to_each_sub_table(v.items, opt)
          else
            table.insert(v, opt)
          end
        else
          v[o] = opt
        end
      end
    end
  end

  return t_to_extend
end

--
-- COMPONENTS ----------------------------------------------------------------
--

-- <COMPONENT DEFINITION>
--
-- [[[ each component table should contain all relevan information necessary when
-- displaying and validating a component within doom ]]]
--
--
-- todo: use doom_component_classes = {
--   ["doom_main_menu"] = {
--   -- TODO: imple display = {}; because this pattern just seems more logical to follow
--     display = {
--        displayer,
--        ordinal,
--     },
--     entries_list (table) | entry_single_template (function),
--   }
-- }

--
-- returns table containing all related configs and functions pertaining to a
-- specific doom module
--
-- local components_module = {
--   main_menu_entries = {
--     displayer,
--     entries_list
--   },
--   module = {
--     opts,
--     displayer,
--     entry_single
--   },
-- }
--
--
-- a component can either be atomic single entry or a full list of all entries
--
-- main_menu_entries = full list of entries. (plural name)
-- module_entry = atomic (singular name)

-- TODO: rename this file to `components/<comp_N>.lua` or move into modules spec . lua?

local result_nodes = {}

--
-- MAIN MENU ------------------------------------------------------------------
--

result_nodes.main_menu = function()
  local main_menu = {
    displayer = function()
      return {
        separator = "",
        items = {
          { width = 4 },
          { width = 20 }, -- TODO: dynamically compute width = widest element in the menu
          { width = 4 },
          -- { remaining = true },
        },
      }
    end,
    ordinal = function() end,
    entries = {},
  }

  extend_entries_list(main_menu.entries, { hl = "TSBoolean" }, {
    {
      items = {
        { "OPEN USER CONFIG" },
      },
      mappings = {
        ["<CR>"] = function()
          vim.cmd(("e %s"):format(require("doom.core.config").source))
        end,
      },
      ordinal = "userconfig",
    },
    {
      items = {
        { "OPEN USER SETTINGS" },
      },
      mappings = {
        ["<CR>"] = function()
          vim.cmd(("e %s"):format(utils.find_config("settings.lua")))
        end,
      },
      ordinal = "usersettings",
    },
  })

  extend_entries_list(main_menu.entries, { hl = "TSFunction" }, {
    {
      items = {
        { "BROWSE USER SETTINGS" },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line, cb)
          DOOM_UI_STATE.query = {
            type = "SHOW_DOOM_SETTINGS",
          }
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "usersettings",
    },
    {
      items = {
        { "BROWSE ALL MODULES" },
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
      items = {
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
          -- DOOM_UI_STATE.selected_component = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "binds",
    },
    {
      items = {
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
          -- DOOM_UI_STATE.selected_component = fuzzy.value
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "autocmds",
    },
    {
      items = {
        { "BROWSE ALL CMDS" }, -- browse all doom commands, then also make browse all user commands.
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
      items = {
        { "BROWSE ALL PACKAGES" }, --
      },
      mappings = {
        ["<CR>"] = function()
          DOOM_UI_STATE.query = {
            type = "MULTIPLE_MODULES",
            origins = { "doom" },
            sections = { "core", "features" },
            components = { "PACKAGES" },
          }

          -- DOOM_UI_STATE.selected_component = fuzzy.value

          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "packages",
    },
    {
      items = {
        { "BROWSE ALL JOBS" }, -- browse job definitions
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "jobs",
    },
    --   , {
    --   -- list running jobs
    -- }
  })

  main_menu.entries = entries_surround_with(
    { "<<", "TSComment" },
    { ">>", "TSComment" },
    main_menu.entries
  )

  extend_entries_list(main_menu.entries, { component_type = "main_menu" })

  -- print(vim.inspect(main_menu))

  return main_menu
end

--
-- MODULES --------------------------------------------------------------------
--

result_nodes.modules = function()
  local modules_component = {
    displayer = function(entry)
      return {
        separator = "| ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(_, _, module)
      module["component_type"] = "modules"
      module["ordinal"] = module.name -- connect strings to make it easy to search modules. improve how?
      -- can I replace this with a function in order to colorize the
      module["items"] = {
        { "MODULE" },
        { module.enabled and "x" or " " },
        { module.origin },
        { module.section },
        { module.name },
      }

      extend_entries_list(module.items, { hl = "TSFunction" })

      module["mappings"] = {
        ["<CR>"] = function(fuzzy, _)
          DOOM_UI_STATE.selected_module = fuzzy.value
          ax.m_edit(fuzzy.value)
        end,
        ["<C-a>"] = function(fuzzy, _)
          DOOM_UI_STATE.query = {
            type = "SHOW_SINGLE_MODULE",
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
    end,
  }
  return modules_component
end

--
-- SETTINGS
--

result_nodes.settings = function()
  local settings_component = {
    displayer = function(entry)
      return {
        separator = " $ ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
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
        component_type = "settings",
        type = "module_setting",
        data = {
          table_path = pc,
          table_value = v,
        },
        items = {
          { "SETTING" },
          { pc_display },
          { v_display },
        },
        ordinal = pc_display,
        mappings = {
          ["<CR>"] = function(fuzzy, line, cb)
            -- DOOM_UI_STATE.query = {
            --   type = "settings",
            -- }
            -- DOOM_UI_STATE.next()
          end,
        },
      }
    end,
  }
  return settings_component
end

--
-- PACKAGES
--

result_nodes.packages = function()
  local packages_component = {
    displayer = function(entry)
      return {
        separator = " % ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
      local spec = v
      if type(k) == "number" then
        if type(v) == "string" then
          spec = { v }
        end
      end
      local repo_name, pkg_name = spec[1]:match("(.*)/([%w%-%.%_]*)$")
      return {
        component_type = "packages",
        type = "module_package",
        data = {
          table_path = k,
          spec = spec,
        },
        items = {
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
    end,
  }
  return packages_component
end

-- result_nodes.packages = function(_, k, v)
--   local spec = v
--   if type(k) == "number" then
--     if type(v) == "string" then
--       spec = { v }
--     end
--   end
--   local repo_name, pkg_name = spec[1]:match("(.*)/([%w%-%.%_]*)$")
--   return {
--     type = "module_package",
--     data = {
--       table_path = k,
--       spec = spec,
--     },
--     items = {
--       { "PKG" },
--       { repo_name },
--       { pkg_name },
--     },
--     ordinal = repo_name .. pkg_name,
--     mappings = {
--       ["<CR>"] = function(fuzzy, line, cb)
--         -- DOOM_UI_STATE.query = {
--         --   type = "settings",
--         -- }
--         -- DOOM_UI_STATE.next()
--       end,
--     },
--   }
-- end

--
-- CONFIGS
--

result_nodes.configs = function()
  local configs_component = {
    displayer = function(entry)
      return {
        separator = " $ ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
      return {
        component_type = "configs",
        type = "module_config",
        data = {
          table_path = k,
          table_value = v,
        },
        items = {
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
    end,
  }
  return configs_component
end

-- result_nodes.configs = function(_, k, v)
--   return {
--     type = "module_config",
--     data = {
--       table_path = k,
--       table_value = v,
--     },
--     items = {
--       { "CFG" },
--       { tostring(k) },
--       { tostring(v) },
--     },
--     ordinal = tostring(k),
--     mappings = {
--       ["<CR>"] = function(fuzzy, line, cb)
--         -- DOOM_UI_STATE.query = {
--         --   type = "settings",
--         -- }
--         -- DOOM_UI_STATE.next()
--       end,
--     },
--   }
-- end

--
-- CMDS
--

result_nodes.cmds = function()
  local cmds_component = {
    displayer = function(entry)
      return {
        separator = " $ ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
      -- TODO: i need to attach k here as well, to table_path
      return {
        component_type = "cmds",
        type = "module_cmd",
        data = {
          name = v[1],
          cmd = v[2],
        },
        ordinal = v[1],
        items = {
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
    end,
  }
  return cmds_component
end

-- result_nodes.cmds = function(_, k, v)
--   -- TODO: i need to attach k here as well, to table_path
--   return {
--     type = "module_cmd",
--     data = {
--       name = v[1],
--       cmd = v[2],
--     },
--     ordinal = v[1],
--     items = {
--       { "CMD" },
--       { tostring(v[1]) },
--       { tostring(v[2]) },
--     },
--     mappings = {
--       ["<CR>"] = function(fuzzy, line, cb)
--         i(fuzzy)
--         -- DOOM_UI_STATE.query = {
--         --   type = "settings",
--         -- }
--         -- DOOM_UI_STATE.next()
--       end,
--     },
--   }
-- end

--
-- AUTOCMDS
--

result_nodes.autocmds = function()
  local autocmds_component = {
    displayer = function(entry)
      return {
        separator = " $ ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
      return {
        component_type = "autocmds",
        type = "module_autocmd",
        data = {
          event = v[1],
          pattern = v[2],
          action = v[3],
        },
        ordinal = v[1] .. v[2],
        items = {
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
    end,
  }
  return autocmds_component
end

-- result_nodes.autocmds = function(_, k, v)
--   return {
--     type = "module_autocmd",
--     data = {
--       event = v[1],
--       pattern = v[2],
--       action = v[3],
--     },
--     ordinal = v[1] .. v[2],
--     items = {
--       { "AUTOCMD" },
--       { v[1] },
--       { v[2] },
--       { tostring(v[3]) },
--     },
--     mappings = {
--       ["<CR>"] = function(fuzzy, line, cb)
--         -- DOOM_UI_STATE.query = {
--         --   type = "settings",
--         -- }
--         -- DOOM_UI_STATE.next()
--       end,
--     },
--   }
-- end

--
-- BINDS
--

result_nodes.binds = function()
  local binds_component = {
    displayer = function(entry)
      return {
        separator = " $ ",
        items = {
          { width = 10 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          { width = 20 },
          -- { width = 4 },
          { remaining = true },
        },
      }
    end,
    ordinal = function()
      -- return module.name
    end,
    entry_template = function(stack, k, v)
      return {
        component_type = "binds",
        type = "module_bind_leaf",
        data = v,
        items = {
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
    end,
  }
  return binds_component
end

-- result_nodes.binds = function(_, _, v)
--   return {
--     type = "module_bind_leaf",
--     data = v,
--     items = {
--       { "BIND" },
--       { v.lhs },
--       { v.name },
--       { v.rhs }, -- {v[1], v[2], tostring(v.options)
--     },
--     ordinal = v.name .. tostring(v.lhs),
--     mappings = {
--       ["<CR>"] = function()
--         -- DOOM_UI_STATE.query = {
--         --   type = "settings",
--         -- }
--         -- DOOM_UI_STATE.next()
--       end,
--     },
--   }
-- end

return result_nodes
