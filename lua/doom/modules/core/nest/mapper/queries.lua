
local M = {}

local ts_query_binds_tables = [[
    ; NOTE: How can I reduce these queries to be smaller
    ;`M.bind = ...`
         (assignment_statement
           (variable_list
             name: (dot_index_expression
               table: (identifier)
               field: (identifier) @field
                  (#lua-match? @field "binds")
                ))
           (expression_list
             value: (table_constructor) @binds.table))

    ;;`M.bind = function() ...`
         (assignment_statement
           (variable_list
             name: (dot_index_expression
               table: (identifier)
               field: (identifier) @field
                  (#lua-match? @field "binds")
                ))
           (expression_list
             value: (function_definition
               parameters: (parameters)
               body: (block) @binds.func_body)))

    ;;`doom.use_keybind({...})`
         (function_call
           name: (dot_index_expression
             table: (identifier)
             field: (identifier) @field
              (#lua-match? @field "use_keybind")
            )
           arguments: (arguments
             (table_constructor) @binds.table))
]]

M.binds_tables = ts_query_binds_tables

return M
