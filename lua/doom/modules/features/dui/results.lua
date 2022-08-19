local ax = require("doom.modules.features.dui.actions")

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- ==============================================================================
-- HIGHLIGHTS                                        *nvim-treesitter-highlights*
--
-- The following is a list of highlights groups, the syntactic elements they
-- apply to, and some examples.
--
-- 							      *hl-TSAttribute*
-- `TSAttribute`
-- Annotations that can be attached to the code to denote some kind of meta
-- information. e.g. C++/Dart attributes.
--
-- 								*hl-TSBoolean*
-- `TSBoolean`
-- Boolean literals: `True` and `False` in Python.
--
-- 							      *hl-TSCharacter*
-- `TSCharacter`
-- Character literals: `'a'` in C.
--
-- 						       *hl-TSCharacterSpecial*
-- `TSCharacterSpecial`
-- Special characters.
--
-- 								*hl-TSComment*
-- `TSComment`
-- Line comments and block comments.
--
-- 							    *hl-TSConditional*
-- `TSConditional`
-- Keywords related to conditionals: `if`, `when`, `cond`, etc.
--
-- 							       *hl-TSConstant*
-- `TSConstant`
-- Constants identifiers. These might not be semantically constant.
-- E.g. uppercase variables in Python.
--
-- 							   *hl-TSConstBuiltin*
-- `TSConstBuiltin`
-- Built-in constant values: `nil` in Lua.
--
-- 							     *hl-TSConstMacro*
-- `TSConstMacro`
-- Constants defined by macros: `NULL` in C.
--
-- 							    *hl-TSConstructor*
-- `TSConstructor`
-- Constructor calls and definitions: `{}` in Lua, and Java constructors.
--
-- 								  *hl-TSDebug*
-- `TSDebug`
-- Debugging statements.
--
-- 								 *hl-TSDefine*
-- `TSDefine`
-- Preprocessor #define statements.
--
-- 								  *hl-TSError*
-- `TSError`
-- Syntax/parser errors. This might highlight large sections of code while the
-- user is typing still incomplete code, use a sensible highlight.
--
-- 							      *hl-TSException*
-- `TSException`
-- Exception related keywords: `try`, `except`, `finally` in Python.
--
-- 								  *hl-TSField*
-- `TSField`
-- Object and struct fields.
--
-- 								  *hl-TSFloat*
-- `TSFloat`
-- Floating-point number literals.
--
-- 							       *hl-TSFunction*
-- `TSFunction`
-- Function calls and definitions.
--
-- 							    *hl-TSFuncBuiltin*
-- `TSFuncBuiltin`
-- Built-in functions: `print` in Lua.
--
-- 							      *hl-TSFuncMacro*
-- `TSFuncMacro`
-- Macro defined functions (calls and definitions): each `macro_rules` in
-- Rust.
--
-- 								*hl-TSInclude*
-- `TSInclude`
-- File or module inclusion keywords: `#include` in C, `use` or `extern crate` in
-- Rust.
--
-- 								*hl-TSKeyword*
-- `TSKeyword`
-- Keywords that don't fit into other categories.
--
-- 							*hl-TSKeywordFunction*
-- `TSKeywordFunction`
-- Keywords used to define a function: `function` in Lua, `def` and `lambda` in
-- Python.
--
-- 							*hl-TSKeywordOperator*
-- `TSKeywordOperator`
-- Unary and binary operators that are English words: `and`, `or` in Python;
-- `sizeof` in C.
--
-- 							  *hl-TSKeywordReturn*
-- `TSKeywordReturn`
-- Keywords like `return` and `yield`.
--
-- 								  *hl-TSLabel*
-- `TSLabel`
-- GOTO labels: `label:` in C, and `::label::` in Lua.
--
-- 								 *hl-TSMethod*
-- `TSMethod`
-- Method calls and definitions.
--
-- 							      *hl-TSNamespace*
-- `TSNamespace`
-- Identifiers referring to modules and namespaces.
--
-- 								     *hl-None*
-- `TSNone`
-- No highlighting (sets all highlight arguments to `NONE`). This group is used
-- to clear certain ranges, for example, string interpolations. Don't change the
-- values of this highlight group.
--
-- 								 *hl-TSNumber*
-- `TSNumber`
-- Numeric literals that don't fit into other categories.
--
-- 							       *hl-TSOperator*
-- `TSOperator`
-- Binary or unary operators: `+`, and also `->` and `*` in C.
--
-- 							      *hl-TSParameter*
-- `TSParameter`
-- Parameters of a function.
--
-- 						     *hl-TSParameterReference*
-- `TSParameterReference`
-- References to parameters of a function.
--
-- 								*hl-TSPreProc*
-- `TSPreProc`
-- Preprocessor #if, #else, #endif, etc.
--
-- 							       *hl-TSProperty*
-- `TSProperty`
-- Same as `TSField`.
--
-- 							 *hl-TSPunctDelimiter*
-- `TSPunctDelimiter`
-- Punctuation delimiters: Periods, commas, semicolons, etc.
--
-- 							   *hl-TSPunctBracket*
-- `TSPunctBracket`
-- Brackets, braces, parentheses, etc.
--
-- 							   *hl-TSPunctSpecial*
-- `TSPunctSpecial`
-- Special punctuation that doesn't fit into the previous categories.
--
-- 								 *hl-TSRepeat*
-- `TSRepeat`
-- Keywords related to loops: `for`, `while`, etc.
--
-- 							     *hl-StorageClass*
-- `TSStorageClass`
-- Keywords that affect how a variable is stored: `static`, `comptime`, `extern`,
-- etc.
--
-- 								 *hl-TSString*
-- `TSString`
-- String literals.
--
-- 							    *hl-TSStringRegex*
-- `TSStringRegex`
-- Regular expression literals.
--
-- 							   *hl-TSStringEscape*
-- `TSStringEscape`
-- Escape characters within a string: `\n`, `\t`, etc.
--
-- 							  *hl-TSStringSpecial*
-- `TSStringSpecial`
-- Strings with special meaning that don't fit into the previous categories.
--
-- 								 *hl-TSSymbol*
-- `TSSymbol`
-- Identifiers referring to symbols or atoms.
--
-- 								    *hl-TSTag*
-- `TSTag`
-- Tags like HTML tag names.
--
-- 							   *hl-TSTagAttribute*
-- `TSTagAttribute`
-- HTML tag attributes.
--
-- 							   *hl-TSTagDelimiter*
-- `TSTagDelimiter`
-- Tag delimiters like `<` `>` `/`.
--
-- 								   *hl-TSText*
-- `TSText`
-- Non-structured text. Like text in a markup language.
--
-- 								 *hl-TSSTrong*
-- `TSStrong`
-- Text to be represented in bold.
--
-- 							       *hl-TSEmphasis*
-- `TSEmphasis`
-- Text to be represented with emphasis.
--
-- 							      *hl-TSUnderline*
-- `TSUnderline`
-- Text to be represented with an underline.
--
-- 								 *hl-TSStrike*
-- `TSStrike`
-- Strikethrough text.
--
-- 								  *hl-TSTitle*
-- `TSTitle`
-- Text that is part of a title.
--
-- 								*hl-TSLiteral*
-- `TSLiteral`
-- Literal or verbatim text.
--
-- 								    *hl-TSURI*
-- `TSURI`
-- URIs like hyperlinks or email addresses.
--
-- 								   *hl-TSMath*
-- `TSMath`
-- Math environments like LaTeX's `$ ... $`.
--
-- 							  *hl-TSTextReference*
-- `TSTextReference`
-- Footnotes, text references, citations, etc.
--
-- 							     *hl-TSEnvironment*
-- `TSEnvironment`
-- Text environments of markup languages.
--
-- 							 *hl-TSEnvironmentName*
-- `TSEnvironmentName`
-- Text/string indicating the type of text environment. Like the name of a
-- `\begin` block in LaTeX.
--
-- 								   *hl-TSNote*
-- `TSNote`
-- Text representation of an informational note.
--
-- 								   *TSWarning*
-- `TSWarning`
-- Text representation of a warning note.
--
-- 								    *TSDanger*
-- `TSDanger`
-- Text representation of a danger note.
--
-- 								   *hl-TSTodo*
-- `TSTodo`
-- Anything that needs extra attention, such as keywords like TODO or FIXME.
--
-- 								   *hl-TSType*
-- `TSType`
-- Type (and class) definitions and annotations.
--
-- 							    *hl-TSTypeBuiltin*
-- `TSTypeBuiltin`
-- Built-in types: `i32` in Rust.
--
-- 							  *hl-TSTypeQualifier*
-- `TSTypeQualifier`
-- Qualifiers on types, e.g. `const` or `volatile` in C or `mut` in Rust.
--
-- 							 *hl-TSTypeDefinition*
-- `TSTypeDefinition`
-- Type definitions, e.g. `typedef` in C.
--
-- 							       *hl-TSVariable*
-- `TSVariable`
-- Variable names that don't fit into other categories.
--
-- 							*hl-TSVariableBuiltin*
-- `TSVariableBuiltin`
-- Variable names defined by the language: `this` or `self` in Javascript.
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- HELPERS
--

-- TODO: rename create entry and add metatable with the `surround char` and other features built into it
--
-- will this work with single-entry tables, eg. `packages` template below?
local function entries_surround_with(start_char, end_char, t_items, search_string)
  for i, _ in pairs(t_items) do
    table.insert(t_items[i], 1, start_char)
    table.insert(t_items[i], end_char)
  end
  return t_items
end

local function extend_entries(...)
  -- if single string -> then just add the highlight group
  local args = { ... }

  if args[1].hl then
    for i, _ in ipairs(args) do
      if i > 1 then
        table.insert(args[i], args[1].hl)
      end
      -- if val < m then
      --    mi = i
      --    m = val
      -- end
    end
  end

  return args
end

--
-- COMPONENTS
--

-- <COMPONENT DEFINITION>
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

-- TODO: rename this file to `components/<comp_N>.lua`
-- and then store all related customization to each component in the
-- same file SO that this file doesn't become insanely huge...
--
-- or maybe this should even be moved into `module_specs.lua`

local result_nodes = {}

--
-- MAIN
--
-- return table
-- {
--  theme = string | function,
--  entry_display_config = table | function,
--  all_results = {},
--  tree_node_cb,
-- }
--

-- components.main_menu
--
-- todo: use doom_component_classes = {
--   ["doom_main_menu"] = {
--     display = {
--        displayer,
--        ordinal,
--     },
--     entries_list | entry_single,
--   }
-- }

result_nodes.main_menu = function()
  local main_menu = {
    displayer = function(entry) -- i believe that I'll recieve the `items` for each entry here
      return {
        -- separator = " | ",
        items = (function()
          return {
            separator = "▏",
            items = {
              { width = 10 },
              { width = 20 },
              { width = 20 },
              { remaining = true },
            },
          }
        end)(),
      }
    end,
    ordinal = function() end,
    -- maybe I should add displayer configs to each entry in the entries table so that this can
    -- be accessed dynamically in the displayer function. The I wouldn't need to configure it here.
    --
    entries = entries_surround_with({ "<<", "TSComment" }, { ">>", "TSComment" }, {
      -- if this is invalid for populating a table > then I can use table.insert to insert
      -- all sublists.
      extend_entries({ hl = "TSBoolean" }, {
        items = {
          { "OPEN USER CONFIG", "TSBoolean" },
        },
        mappings = {
          ["<CR>"] = function()
            vim.cmd(("e %s"):format(require("doom.core.config").source))
          end,
        },
        ordinal = "userconfig",
      }, {
        items = {
          { "OPEN USER SETTINGS", "TSBoolean" },
        },
        mappings = {
          ["<CR>"] = function() end,
        },
        ordinal = "usersettings",
      }),
      {
        items = {
          { "BROWSE USER SETTINGS", "TSError" },
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
      -- {
      --   -- list running jobs
      -- },
    }),
  }

  local doom_menu_items = {
    {
      items = {
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
      items = {
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
      items = {
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
      items = {
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

          -- DOOM_UI_STATE.selected_component = fuzzy.value

          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "packages",
    },
    {
      items = {
        { "BROWSE ALL JOBS" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "jobs",
    },
  }

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
  module["items"] = {
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
    items = {
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
end

--
-- BINDS
--

result_nodes.binds = function(_, _, v)
  return {
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
end

return result_nodes
