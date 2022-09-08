
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; QUERY                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; STATIC AND STRING.FORMAT [[]]
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
;; (
;; assignment_statement [15, 0] - [26, 2]
;;   variable_list [15, 0] - [15, 36]
;;     name: dot_index_expression [15, 0] - [15, 36]
;;       table: identifier [15, 0] - [15, 7]
;;       field: identifier [15, 8] - [15, 36]
;;   expression_list [15, 39] - [26, 2]
;;     value: string [15, 39] - [26, 2]
;; )
