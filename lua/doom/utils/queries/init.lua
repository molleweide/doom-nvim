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
    rhs_name = '\\"' .. rhs_name .. '\\"'
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

queries.cmd_table = function(cmd)
  print("CMD >>>", vim.inspect(cmd))

  -- CMD >>> {
  --   component_type = "cmds",
  --   data = {
  --     cmd = <function 1>,
  --     name = "DoomReload"
  --   },
  --   items = { { "CMD", "TSError" }, { "DoomReload", "TSError" }, { "function: 0x018b14a630", "TSError" } },
  --   mappings = {
  --     ["<C-e>"] = <function 2>,
  --     ["<C-h>"] = <function 3>,
  --     ["<CR>"] = <function 4>
  --   },
  --   ordinal = "DoomReload",
  --   type = "module_cmd"
  -- }

  --   table_constructor
  --     field [405, 4] - [405, 20]
  --       value: string [405, 4] - [405, 20]
  --     field [406, 4] - [427, 7]
  --       value: function_definition [406, 4] - [427, 7]
  return string.format(
    [[
      (table_constructor
        (field value: (string) @name)
        (field value: [(string) (function_definition)] @action)
      )
    ]]
    -- name,
    -- action
  )
end

-- Assume first two fields are uniqe
queries.autocmd_table = function(autocmd)
  print("AUTOCMD >>>", vim.inspect(autocmd))

  -- BIND >>> {
  --   component_type = "autocmds",
  --   data = {
  --     action = <function 1>,
  --     event = "BufWinEnter",
  --     pattern = "*.lua"
  --   },
  --   items = { { "AUTOCMD", "TSDebug" }, { "BufWinEnter", "TSDebug" }, { "*.lua", "TSDebug" }, { "function: 0x01782d84f0", "TSDebug" } },
  --   mappings = {
  --     ["<C-e>"] = <function 2>,
  --     ["<C-h>"] = <function 3>,
  --     ["<CR>"] = <function 4>
  --   },
  --   ordinal = "BufWinEnter*.lua",
  --   type = "module_autocmd"
  -- }

  return string.format(
    [[
      (field
        value: (table_constructor
          (field value: (string) @event, (todo...))
          (field value: (string) @pattern ())
          (field value: (function_definition) @fn)
        )
      )
    ]]
    -- event,
    -- pattern
  )
end

queries.binds_table = function(bind)
  print("BIND >>>", vim.inspect(bind))

  -- todo: capture the field nodes here instead and play around with
  -- traversing the node and learning how that works more

  -- BIND >>> {
  --   component_type = "binds",
  --   data = { "h", <function 1>,
  --     lhs = "<leader>gch",
  --     name = "commit single hunk",
  --     rhs = <function 1>
  --   },
  --   items = { { "BIND", "TSKeywordFunction" }, { "<leader>gch", "TSKeywordFunction" }, { "commit single hunk", "TSKeywordFunction" }, { <function 1>, "TSKeywordFunction" } },
  --   mappings = {
  --     ["<C-e>"] = <function 2>,
  --     ["<C-h>"] = <function 3>,
  --     ["<CR>"] = <function 4>
  --   },
  --   ordinal = "commit single hunk<leader>gch",
  --   type = "module_bind_leaf"
  -- }

  return string.format(
    -- TODO: read query docs and make the query more specific and secure
    [[
      (field
        value: (table_constructor
          ;; First has to be a string
          (field value: (string) @str)
          ;; [ string / func / identifier]
          (field value: (dot_index_expression field: (identifier)) @f)
          ;; third conditional [ name string || name prop ] ;; nothing else
          (field name: ( identifier ) value: ( string ))
        )
      )
    ]]
    -- event,
    -- pattern
  )
end

queries.binds_leader_t = function(bind)
  -- only find leader <leader> table
end

queries.binds_branch = function(bind)
  -- only find branches
  --
  --    it can either be a leader branch or regular branch
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
