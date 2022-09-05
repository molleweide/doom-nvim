;highlight ts queries with `lisp`
(variable_declaration
  (assignment_statement
    (variable_list)
    (expression_list
      value: [
              (function_call
                name: (dot_index_expression
                  )
                arguments: (arguments
                    (string) @lisp
                  )
             )
            (string) @lisp
      ]
    )
  )
)
