local parse = require("doom.utils.queries.utils").parse

local queries = {}

-- TODO:
--
--
--  - how to handle case when configs are attached via dot expression
--      and not by field inside of tbl???
--
--      we need to build queries that capture various types of
--      statements n stuff in modules so that.

queries.format = function(...)
  return string.format(...)
end

queries.root_mod_name_by_section = function(name, section)
  return string.format(
    [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor
              (field value: (string) @module_string (#eq? @module_string "\"%s\""))
        )
      )
  ) (#eq? @section_key "%s")
))
]],
    name,
    section
  )
end

queries.root_all_comments_from_section = function(section)
  return string.format(
    [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor (comment) @section_comment)
      )
  ) (#eq? @section_key "%s")
))
]],
    section
  )
end

queries.root_get_section_table_by_name = function(section)
  return string.format(
    [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor) @section_table)
  ) (#eq? @section_key "%s")
))
  ]],
    section
  )
end

-----------------------------------------------------------------------------
--

queries.field = function(lhs_name, rhs_name)
  local rhs_tag
  if type(rhs_name) == "string" then
    rhs_name = "\\\"" .. rhs_name .. "\\\""
    rhs_tag = "string"
  -- else
  --   rhs_tag = rhs_name
  end

  return parse({
    field = {
      _name = {
        identifier = {
          "@name",
          "eq",
          "@name",
          lhs_name,
        },
      },
      _value = {
        -- 100 -> "number"
        --
        -- ALTERNATIVES:
        --
        --    - inside of results when we collect entries.
        --
        --    - inside of parser > this would be a nice fallback
        --
        [rhs_tag] = {
          "@value",
          "eq",
          "@value",
          rhs_name,
        },
      },
    },
  })
end

queries.pkg_table = function(table_path, spec_one)
  return string.format(
    [[
      (field
        name: (string) @name (#eq? @name "\"%s\"")
        value: (table_constructor
          (field
            value: (string) @repo
              (#eq? @repo "\"%s\"")
          )
        ) @pkg_table
      )
    ]],
    table_path,
    spec_one
  )
end

-- queries.package()
-- queries.config()
-- queries.cmd()
-- queries.autocmd()
-- queries.bind()

-- queries.asst_table_table = {
--   assignment_statement = {
--     variable_list = {
--       _name = {
--         dot_index_expression = {
--           _table = { identifier = {} },
--           _field = {
--             identifier = { "@varl_tbl_name", "eq", "@varl_tbl_name", type },
--           },
--         },
--       },
--     },
--     expression_list = { _value = { table_constructor = { "@expr_tbl_constr" } } },
--   },
-- }

-- INJECT LUA TABLE QUERY HIGHLIGHTS
-- @param type    M.xx = <type>
-- @param field   name M.<field>
-- @param
queries.assignment_statement = function(type, lhs_name, in_tbl)
  -- print(vim.inspect(type))

  if type == "func" then
    return parse({
      assignment_statement = {
        variable_list = {
          _name = {
            bracket_index_expression = {
              _table = {
                dot_index_expression = {
                  _table = {
                    identifier = {},
                  },
                  _field = {
                    identifier = {
                      "@varl_name",
                      "eq",
                      "@varl_name",
                      lhs_name,
                    },
                  },
                },
              },
              _field = { string = {} },
            },
          },
        },
        expression_list = {
          _value = {
            function_definition = { "@rhs" },
          },
        },
      },
    })
  else
    return parse({
      assignment_statement = {
        variable_list = {
          _name = {
            dot_index_expression = {
              _table = { identifier = {} },
              _field = {
                identifier = { "@varl_name", "eq", "@varl_name", lhs_name },
              },
            },
          },
        },
        expression_list = { _value = { table_constructor = { "@rhs" } } },
      },
    })
  end
end

queries.comp_unit = function(c)
  print(vim.inspect(c))

  -- @COMPONENT
  -- {
  --   component_type = "settings",
  --   data = {
  --     table_path = { "gitsigns", "numhl" },
  --     table_value = false
  --   },
  --   items = { { "SETTING", "TSFloat" }, { "gitsigns.numhl", "TSFloat" }, { "false", "TSFloat" } },
  --   mappings = {
  --     ["<C-e>"] = <function 1>,
  --     ["<C-h>"] = <function 2>,
  --     ["<CR>"] = <function 3>
  --   },
  --   ordinal = "gitsigns.numhl",
  --   type = "module_setting"
  -- }

  -- TODO: THIS COULD ALSO BE MADE CONDITIONALLY BY TAKING THE `C.DATA.TABLE_VALUE`
  if c.component_type == "settings" then
    return parse({
      field = {
        _name = {
          identifier = {
            "@name",
            "eq",
            "@name",
            c.data.table_path[#c.data.table_path],
          },
        },
        _value = {
          -- 100 -> "number"
          --
          -- ALTERNATIVES:
          --
          --    - inside of results when we collect entries.
          --
          --    - inside of parser > this would be a nice fallback
          --
          [tostring(c.data.table_value)] = {
            "@value",
            "eq",
            "@value",
            tostring(c.data.table_value),
          },
        },
      },
    })
  elseif c.type == "packages" then
    -- local ts_query_package = [[
    --     (field
    --       name: (string) @name (#eq? @name "\"nvim-cmp\"")
    --       value: (table_constructor
    --         (field
    --           value: (string) @repo
    --             (#eq? @repo "\"hrsh7th/nvim-cmp\"")
    --         )
    --       )
    --     )
    --   ]]
    return parse({
      field = {
        _name = { string = { "name", "eq", "name", name } },
        _value = {
          table_constructor = { field = { _value = { string = { "repo", "eq", "repo", name } } } },
        },
      },
    })
  elseif c.type == "configs" then
    -- local ts_query_config = [[
    --      (assignment_statement
    --       (variable_list
    --         name: (bracket_index_expression
    --           table: (dot_index_expression
    --             table: ( identifier )
    --             field: ( identifier )
    --           )
    --           field: (string) @name
    --         )
    --       )
    --       (expression_list
    --         value: (function_definition
    --           parameters: (parameters)
    --         ) @func
    --       )
    --     )
    --   ]]
    return parse({})
  elseif c.type == "cmds" then
    -- local ts_query_cmd = [[
    --     (assignment_statement
    --       (variable_list
    --         name: (dot_index_expression
    --           table: (identifier)
    --           field: (identifier) @base
    --         )
    --       )
    --       (expression_list
    --         value:  (table_constructor
    --             (field value: (table_constructor
    --                 (field
    --                   value: (string) @name (#eq? @name "\"DoomCreateNewModule\"")
    --                   )
    --                 (field
    --                   value: (function_definition
    --                            parameters: (parameters)))
    --               ) @cmd_tbl
    --             )
    --         )
    --       )
    --     )
    --   ]]
    return parse({})
  elseif c.type == "autocmds" then
    -- local ts_query_autocmd = [[
    --     (assignment_statement
    --       (variable_list
    --         name: (dot_index_expression
    --          table: (identifier)
    --          field: (identifier) @base
    --         )
    --       )
    --       (expression_list
    --         value: (table_constructor
    --           (field
    --             value: (table_constructor
    --               (field value: (string) @event)
    --               (field value: (string) @pattern)
    --               (field value: (function_definition) @fn)
    --             )
    --           )
    --         )
    --       )
    --     )
    --   ]]
    return parse({})
  elseif c.type == "binds" then
    -- local ts_query_bind = [[
    --     (assignment_statement
    --       (variable_list
    --         name: (dot_index_expression
    --           table: (identifier)
    --           field: (identifier) @base
    --         )
    --       )
    --       (expression_list
    --         value: (table_constructor
    --           (field
    --             value: (table_constructor
    --               (field value: (string) @str)
    --               (field value: (dot_index_expression field: (identifier)) @f)
    --               (field name: ( identifier ) value: ( string ))
    --             )
    --           )
    --         )
    --       )
    --     )
    --   ]]
    return parse({})
  end

  --   -- if opts.selected_component.type == "module_setting" then
  --   --   return string.format(ts_query_setting, xxx)
  --   -- elseif opts.selected_component.type == "module_package" then
  --   --   return string.format(ts_query_package, xxx)
  --   -- elseif opts.selected_component.type == "module_config" then
  --   --   return string.format(ts_query_config, xxx)
  --   -- elseif opts.selected_component.type == "module_cmd" then
  --   --   return string.format(ts_query_cmd, xxx)
  --   -- elseif opts.selected_component.type == "module_autocmd" then
  --   --   return string.format(ts_query_autocmd, xxx)
  --   -- elseif opts.selected_component.type == "module_bind" then
  --   --   return string.format(ts_query_bind, xxx)
  --   -- end
end

return queries
