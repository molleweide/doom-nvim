local queries = {}

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

-- queries.ts_query_template_s_and_c = [[
-- (return_statement (expression_list
--   (table_constructor
--       (field
--         name: (identifier) @section_key
--         value: (table_constructor
--               (comment) @section_comment
--               (field value: (string) @module_string (#eq? @module_string "\"%s\""))
--         )
--       )
--   ) (#eq? @section_key "%s")
-- ))
-- ]]
--
-- queries.ts_query_template_section_table = [[
-- (return_statement (expression_list
--   (table_constructor
--       (field
--         name: (identifier) @section_key
--         value: (table_constructor) @section_table)
--   ) (#eq? @section_key "%s")
-- ))
-- ]]

--
-- MODULE QUERIES
--

-- types of funcs
--
--     get_component table
--     get_child_table
--     get_component_entry_by_data
--          pkg spec -> by name string
--          bind tbl -> by unique prop combo

-- pass (settings|packages|configs|cmds|autocmds|binds)
-- return query for container table
queries.tsq_get_comp_containers = function(component)
  local ts_query_components_table
  if component == "configs" then
    ts_query_components_table = string.format(
      [[
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
  ]],
      component
    )
  else
    ts_query_components_table = string.format(
      [[
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
  ]],
      component
    )
  end

  return ts_query_components_table
end

queries.tsq_get_comp_selected = function(opts)
  -- action = "component_edit_sel",
  -- selected_module = DOOM_UI_STATE.selected_module,
  -- selected_component = sel,
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
