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

-- queries.setting()
-- queries.package()
-- queries.config()
-- queries.cmd()
-- queries.autocmd()
-- queries.bind()

-- >>> (assignment_statement
--   (variable_list
--     name:
--       (bracket_index_expression
--         table:
--           field:
--             (string
--             )
--
--           (dot_index_expression
--             table:
--               (identifier
--               )
--
--             field:
--               (identifier
--               ) @comp_tbl_name (#eq? @comp_tbl_name "configs")
--
--           )
--
--       )
--
--   )
--   (expression_list
--     value:
--       (function_definition
--       ) @component_container
--
--   )
-- )
queries.component_container = function(comp, type)
  -- print(vim.inspect(comp, type))
  if type == "configs" then
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
                      "@comp_tbl_name",
                      "eq",
                      "@comp_tbl_name",
                      type,
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
            function_definition = { "@component_container" },
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
                identifier = { "@comp_tbl_name", "eq", "@comp_tbl_name", type },
              },
            },
          },
        },
        expression_list = { _value = { table_constructor = { "@component_container" } } },
      },
    })
  end
end

queries.comp_unit = function(opts)
  --   local ts_query_setting = [[
  --     (field
  --       name: (identifier) @name
  --         (#eq? @name "debug")
  --       ;;
  --       value: [
  --         (false)
  --         (number)
  --         (string)
  --     ] @value
  --         (#eq? @value "false")
  --     )
  --   ]]
  --
  --   local ts_query_package = [[
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
  --   local ts_query_config = [[
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
  --   local ts_query_cmd = [[
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
  --   local ts_query_autocmd = [[
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
  --
  --   local ts_query_bind = [[
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
  --
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
