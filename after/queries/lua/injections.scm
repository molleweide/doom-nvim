
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; QUERY                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; STATIC AND STRING.FORMAT
;
; local var`ts_query...`
;
(variable_declaration
  (assignment_statement
    ; ts_query|tsq|query|q
    (variable_list) @vl (#match? @vl "^ts_query")
    (expression_list
      value: [
              (function_call
                name: (dot_index_expression
                  )
                arguments: (arguments
                    (string) @query
                  )
             )
            (string) @query
      ]
    )
  )
)

;
; STATIC
;
; queries.<name> = [[...]]
;
(assignment_statement
  (variable_list
    name: (dot_index_expression
      table: ( identifier ) @name (#eq? @name "queries")
      field: ( identifier )
      )
  )
  (expression_list
    value: ( string ) @query
    )
)
