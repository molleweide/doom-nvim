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
          -- DOOM_UI_STATE.selected_component = fuzzy.value
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
          -- DOOM_UI_STATE.selected_component = fuzzy.value
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

          -- DOOM_UI_STATE.selected_component = fuzzy.value

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
