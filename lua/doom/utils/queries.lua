local queries = {}

-- TODO: maintain proper indentation for queries

-- TODO: refactoring.nvim -> query_generation/lang/lua.lua
--        and move my helpers to there.

--
-- ROOT MODULES QUERIES
--

queries.ts_query_template_mod_string = [[
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

queries.ts_query_template_mod_comment = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor (comment) @section_comment)
      )
  ) (#eq? @section_key "%s")
))
]]

--
-- MODULE QUERIES
--

--
-- REFACTOR:
--    - queries below
--    - extract patterns
--    - build compose helpers.
--    -
--
-- return query for container table
queries.tsq_get_comp_containers = function(component)
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

queries.tsq_get_comp_selected = function(opts)
  local ts_query_setting = [[
    (field
      name: (identifier) @name
        (#eq? @name "debug")
      ;; how to capture any value below.
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

  if opts.selected_component.type == "module_setting" then
    return string.format(ts_query_setting, xxx)
  elseif opts.selected_component.type == "module_package" then
    return string.format(ts_query_package, xxx)
  elseif opts.selected_component.type == "module_config" then
    return string.format(ts_query_config, xxx)
  elseif opts.selected_component.type == "module_cmd" then
    return string.format(ts_query_cmd, xxx)
  elseif opts.selected_component.type == "module_autocmd" then
    return string.format(ts_query_autocmd, xxx)
  elseif opts.selected_component.type == "module_bind" then
    return string.format(ts_query_bind, xxx)
  end
end

queries.mod_get_query_for_child_table = function(components, child_specs)
  -- use for:
  --  packages; cmds; autocmds; binds
  local ts_query_child_table = string.format(
    [[
(assignment_statement
  (variable_list
      name:
        (dot_index_expression
          table: (identifier)
          field: (identifier) @i
        )
  )
  ( expression_list
    value: (table_constructor
      (field
        name: ( string ) @s2
        value: ( table_constructor ) @t2
      )
    ) @components_table
  )
)(#eq? @i "packages")
]],
    components
  )
end

queries.mod_get_query_for_bind = function()

  -- I assume that all binds are unique so it should be possible
  -- to make a single query quite easy to get explicit ranges
  -- for a single table.

  -- HACK: THIS IS ACTUALLY GOING TO BE SO MUCH FUN TO FIX THIS.

  -- recieve data here and inspect what I need in order to
  -- see what kinds of queries I can make.

  -- should work for any bind.
  -- so this one has to be flexible.
end

queries.ts_query_mod_get_pkg_spec = function(pkg_name)
  -- get package spec query by name.
  local ts_query = string.format([[
    ()
  ]])
end

queries.ts_query_mod_get_pkg_config = [[
  ()
]]

queries.ts_query_mod_get_cmd = [[
  ()
]]

queries.ts_query_autocmd_table = [[
  ()
]]
queries.ts_query_bind_table = [[
()
]]

return queries
