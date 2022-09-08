
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INJECT TS QUERY INTO LUA STRINGS AND LUA-QUERY-TBLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

;
; STRING.FORMAT([[]])
;

;
; LUA TABLE QUERIES
;
