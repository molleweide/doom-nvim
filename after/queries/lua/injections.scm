
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


;; ;
;; ; FUNCTION RETURN
;; ;
;; (assignment_statement [13, 0] - [26, 3]
;;   variable_list [13, 0] - [13, 32]
;;     name: dot_index_expression [13, 0] - [13, 32]
;;       table: identifier [13, 0] - [13, 7]
;;       field: identifier [13, 8] - [13, 32]
;;   expression_list [13, 35] - [26, 3]
;;     value: function_definition [13, 35] - [26, 3]
;;       parameters: parameters [13, 43] - [13, 58]
;;         name: identifier [13, 44] - [13, 48]
;;         name: identifier [13, 50] - [13, 57]
;;       body: block [14, 2] - [25, 3]
;;         return_statement [14, 2] - [25, 3]
;;           expression_list [14, 9] - [25, 3]
;;             function_call [14, 9] - [25, 3]
;;               name: dot_index_expression [14, 9] - [14, 22]
;;                 table: identifier [14, 9] - [14, 15]
;;                 field: identifier [14, 16] - [14, 22]
;;               arguments: arguments [14, 22] - [25, 3]
;;                 string [14, 23] - [25, 2]
;; )
