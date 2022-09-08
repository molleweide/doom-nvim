local query_parse = require("doom.utils.queries.utils").parse

local queries = {}

-- TODO:
--
--
--  - how to handle case when configs are attached via dot expression
--      and not by field inside of tbl???

--
-- ROOT MODULES QUERIES
--

-- todo: add string.format to these static queries

queries.root_mod_name_by_section = function(section, name)
  local ts_query = [[
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
]]
  return ts_query
end

queries.root_all_comments_from_section = function(section)
  local ts_query = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor (comment) @section_comment)
      )
  ) (#eq? @section_key "%s")
))
]]
  return ts_query
end

queries.mod_get_component_table = function(component)
  local q_ = queries.parse({
    field = {
      _name = {
        identifier = {
          "@c_id",
          { "#eq?", "@c_id", "false" },
        },
      },
      _value = {
        false_ = {
          "@c_false",
          {
            "#eq?",
            "@c_false",
            "false",
          },
        },
      },
      { "#eq?", "@c_field", "xxx" },
    },
  })

  local ts_query_configs = [[
    (assignment_statement
      (variable_list
        name: (bracket_index_expression
            table: (dot_index_expression
              table: (identifier)
              field: (identifier) @comp_tbl_name (#eq? @comp_tbl_name "%s"))
            field: (string)
        )
      )
      (expression_list
        value: (function_definition) @comp_unit
      )
    )
  ]]
  local ts_query_others = [[
    (assignment_statement
      (variable_list
        name:
          (dot_index_expression
            table: (identifier)
            field: (identifier) @comp_tbl_name
            (#eq? @comp_tbl_name "%s")
          )
      )
      (expression_list
        value: (table_constructor) @comp_unit
      )
    )
  ]]
  return string.format(component == "configs" and ts_query_configs or ts_query_others, component)
end

queries.mod_get_component_unit = function(opts)
  local ts_query_setting = [[
    (field
      name: (identifier) @name
        (#eq? @name "debug")
      ;;
      value: [
        (false)
        (number)
        (string)
    ] @value
        (#eq? @value "false")
    )
  ]]

  local ts_query_package = [[
    (field
      name: (string) @name (#eq? @name "\"nvim-cmp\"")
      value: (table_constructor
        (field
          value: (string) @repo
            (#eq? @repo "\"hrsh7th/nvim-cmp\"")
        )
      )
    )
  ]]
  local ts_query_config = [[
     (assignment_statement
      (variable_list
        name: (bracket_index_expression
          table: (dot_index_expression
            table: ( identifier )
            field: ( identifier )
          )
          field: (string) @name
        )
      )
      (expression_list
        value: (function_definition
          parameters: (parameters)
        ) @func
      )
    )
  ]]
  local ts_query_cmd = [[
    (assignment_statement
      (variable_list
        name: (dot_index_expression
          table: (identifier)
          field: (identifier) @base
        )
      )
      (expression_list
        value:  (table_constructor
            (field value: (table_constructor
                (field
                  value: (string) @name (#eq? @name "\"DoomCreateNewModule\"")
                  )
                (field
                  value: (function_definition
                           parameters: (parameters)))
              ) @cmd_tbl
            )
        )
      )
    )
  ]]
  local ts_query_autocmd = [[
    (assignment_statement
      (variable_list
        name: (dot_index_expression
         table: (identifier)
         field: (identifier) @base
        )
      )
      (expression_list
        value: (table_constructor
          (field
            value: (table_constructor
              (field value: (string) @event)
              (field value: (string) @pattern)
              (field value: (function_definition) @fn)
            )
          )
        )
      )
    )
  ]]

  local ts_query_bind = [[
    (assignment_statement
      (variable_list
        name: (dot_index_expression
          table: (identifier)
          field: (identifier) @base
        )
      )
      (expression_list
        value: (table_constructor
          (field
            value: (table_constructor
              (field value: (string) @str)
              (field value: (dot_index_expression field: (identifier)) @f)
              (field name: ( identifier ) value: ( string ))
            )
          )
        )
      )
    )
  ]]

  -- if opts.selected_component.type == "module_setting" then
  --   return string.format(ts_query_setting, xxx)
  -- elseif opts.selected_component.type == "module_package" then
  --   return string.format(ts_query_package, xxx)
  -- elseif opts.selected_component.type == "module_config" then
  --   return string.format(ts_query_config, xxx)
  -- elseif opts.selected_component.type == "module_cmd" then
  --   return string.format(ts_query_cmd, xxx)
  -- elseif opts.selected_component.type == "module_autocmd" then
  --   return string.format(ts_query_autocmd, xxx)
  -- elseif opts.selected_component.type == "module_bind" then
  --   return string.format(ts_query_bind, xxx)
  -- end
end

-- queries.mod_get_query_for_child_table = function(components, child_specs)
--   local ts_query_child_table = string.format(
--     [[
-- (assignment_statement
--   (variable_list
--       name:
--         (dot_index_expression
--           table: (identifier)
--           field: (identifier) @i
--         )
--   )
--   ( expression_list
--     value: (table_constructor
--       (field
--         name: ( string ) @s2
--         value: ( table_constructor ) @t2
--       )
--     ) @components_table
--   )
-- )(#eq? @i "packages")
-- ]],
--     components
--   )
-- end

return queries
