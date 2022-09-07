local crawl = require("doom.utils.tree").traverse_table

local queries = {}

-- TODO: maintain proper indentation for queries

-- TODO: refactoring.nvim -> query_generation/lang/lua.lua
--        and move my helpers to there.

--
-- folds
--

local ts_query_folds = [[
  [
 (for_in_statement)
 (for_statement)
 (while_statement)
 (repeat_statement)
 (if_statement)
 (do_statement)
 (function_definition)
 (local_function)
 (function)
 (table)
] @fold
]]

--
-- highlights
--
--

local ts_query_hl = [[
;;; Highlighting for lua

;;; Builtins
(self) @variable.builtin

;; Keywords

(if_statement
[
  "if"
  "then"
  "end"
] @conditional)

[
  "else"
  "elseif"
  "then"
] @conditional

(for_statement
[
  "for"
  "do"
  "end"
] @repeat)

(for_in_statement
[
  "for"
  "do"
  "end"
] @repeat)

(while_statement
[
  "while"
  "do"
  "end"
] @repeat)

(repeat_statement
[
  "repeat"
  "until"
] @repeat)

(do_statement
[
  "do"
  "end"
] @keyword)

[
 "in"
 "local"
 (break_statement)
 "goto"
] @keyword

"return" @keyword.return

;; Operators

[
 "not"
 "and"
 "or"
] @keyword.operator

[
"="
"~="
"=="
"<="
">="
"<"
">"
"+"
"-"
"%"
"/"
"//"
"*"
"^"
"&"
"~"
"|"
">>"
"<<"
".."
"#"
 ] @operator

;; Punctuation
["," "." ":" ";"] @punctuation.delimiter

;; Brackets
[
 "("
 ")"
 "["
 "]"
 "{"
 "}"
] @punctuation.bracket

;; Variables
(identifier) @variable

;; Constants
[
(false)
(true)
] @boolean
(nil) @constant.builtin
(spread) @constant ;; "..."
((identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

;; Functions
(function [(function_name) (identifier)] @function)
(function ["function" "end"] @keyword.function)

(local_function (identifier) @function)
(local_function ["function" "end"] @keyword.function)

(variable_declaration
 (variable_declarator (identifier) @function) (function_definition))
(local_variable_declaration
 (variable_declarator (identifier) @function) (function_definition))

(function_definition ["function" "end"] @keyword.function)

(property_identifier) @property

(function_call
  [((identifier) @variable (method) @method)
   ((_) (method) @method)
   (identifier) @function
   (field_expression (property_identifier) @function)]
  . (arguments))

(function_call
  (identifier) @function.builtin
  (#any-of? @function.builtin
    ;; built-in functions in Lua 5.1
    "assert" "collectgarbage" "dofile" "error" "getfenv" "getmetatable" "ipairs"
    "load" "loadfile" "loadstring" "module" "next" "pairs" "pcall" "print"
    "rawequal" "rawget" "rawset" "require" "select" "setfenv" "setmetatable"
    "tonumber" "tostring" "type" "unpack" "xpcall"))

;; built-in next function
(next) @function.builtin

;; Parameters
(parameters
  (identifier) @parameter)

;; Nodes
(table ["{" "}"] @constructor)
(comment) @comment
(string) @string
(number) @number
(label_statement) @label
; A bit of a tricky one, this will only match field names
(field . (identifier) @field (_))
(shebang) @comment

;; Error
(ERROR) @error

]]

--
-- indents
--

local ts_query_indents = [[
[
  (function_definition)
  (variable_declaration)
  (local_variable_declaration)
  (field)
  (local_function)
  (function)
  (if_statement)
  (for_statement)
  (for_in_statement)
  (repeat_statement)
  (return_statement)
  (while_statement)
  (table)
  (arguments)
  (do_statement)
] @indent

[
  "end"
  "until"
  "{"
  "}"
  "("
  ")"
  "then"
  (else)
  (elseif)
] @branch

(comment) @ignore

]]

--
-- locals
--

local ts_query_locals = [[
;;; DECLARATIONS AND SCOPES

;; Variable and field declarations
((variable_declarator
   (identifier) @definition.var))

((variable_declarator
   (field_expression . (_) @definition.associated (property_identifier) @definition.var)))

;; Parameters
(parameters (identifier) @definition.parameter)

;; Loops
((loop_expression
   (identifier) @definition.var))

;; Function definitions
((function
   (function_name
     (function_name_field
       (identifier) @definition.associated . (property_identifier) @definition.method)))
 (#set! definition.method.scope "parent"))

((function
   (function_name (identifier) @definition.function))
 (#set! definition.function.scope "parent"))

((local_function (identifier) @definition.function)
 (#set! definition.function.scope "parent"))

(local_variable_declaration
  (variable_declarator (identifier) @definition.function) . (function_definition))

;; Scopes
[
  (program)
  (function)
  (local_function)
  (function_definition)
  (if_statement)
  (for_in_statement)
  (repeat_statement)
  (while_statement)
  (do_statement)
] @scope

;;; REFERENCES
[
  (identifier)
  (property_identifier)
] @reference


]]

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--
-- COMPOSE FUNCS
--

local function wrap(str, id)
  return string.format(
    [[(%s
    %s
  )]],
    id,
    str
  )
end

local function make_sexpr() end

-- local number = function(name, value) end
-- local string = function(name, value) end
-- local string = function(name, value) end

-- todo: there is a generalized pattern
--  for thes syntax (x ...)

-- TODO: USE TREE CRAWLER TO RENDER QUERY FROM TREE.
-- !!!!!
--
--      look at how

queries.parse = function(query)

  -- 1 branch pre / post
  -- 2. branch insert into acc.
  -- 3. make sure nothing breaks.
  --
  -- DO THIS BY CREATING TWO NEW TEMPORARY FUNCS THAT I USE

   local results =  crawl({
    tree = query,
    -- edge = function(_, k, v) end,
    branch = function(s,k,v)
      return v
    end,
    branch_post = function(s,k,v)
    end,
    node = function(s, k, v)
      return v
    end,
    filter = function(_, l, r)
      -- k = {} is a branch
      return not (l.is_str and r.is_tbl)
    end,
    log = {
      use = true,
      mult = 4,
      name_string = "query parser",
      cat = 2,
      inspect = true,
      new_line = true,
      frame = true,
      separate = true,
    },
  })

  local str = ""
  for k, v in ipairs(results) do
    str = str .. v
  end

  return str

end

queries.node = function(...)
  local args = ...
  local str
  local pre = "("
  local post = ")"

  if #args == 0 then
    return false
  end

  str = pre .. args[1]

  -- if not args[2] then
  --   return str .. post
  -- end

  -- get children
  for k,v in ipairs(args) do
    if k < 4 then
      ::continue::
    end
    -- if type func else error
    str = str .. "\n" .. args[k]()
  end

  str = str .. "\n" .. post

  -- capture
  if args[2] then
    str = str .. " @" .. c -- str = add_capture(str, c)
  end

  -- sexpr
  if args[3] then
    str = str .. args[3]()-- [[(#eq? @c "match_str")]] -- .. add_sexpr(str, s)
  end

  return str
end

queries.prop = function(...)
  local args = ...
end
queries.sexpr = function(...)
  local args = ...
end

-- NOTE: it is going to be a bit of a pain to do this first one,
--    but then when the pattern arises then I'll be able to
--    refactor this into a nice lib.
--
-- HANDLE CASES
--    only value (field value: )
--    child callbacks.
--
-- q.field(
--   q._name(
--       q.identifier, -- identifier()
--       "cname",
--       q.sexpr("eq", compare_name)
--    ),
--    q._value(
--      q.false_(),  -- false_()
--      "cvalue",
--      q.sexpr("eq", compare_value)
--    )
-- )

local _name = function(t, c, s)
  local str = string.format("name: (%s)", t)
  -- append capture
  if c then
    str = str .. " @" .. c -- str = add_capture(str, c)
  end
  -- sexpr
  if s then
    str = str .. [[(#eq? @c "match_str")]] -- .. add_sexpr(str, s)
  end
end

-- rename: t -> x
--
-- false|number|string|true|nil|table_constructor|function
local _value = function(t, c, s)
  local str = string.format("value: (%s)", t)
  -- append capture
  if c then
    str = str .. " @" .. c -- str = add_capture(str, c)
  end
  if s then
    str = str .. [[(#eq? @c "match_str")]] -- .. add_sexpr(str, s)
  end
end

local field = function(cname, cvalue, vtype, child_queries_cb)
  if not cvalue then
    return "(field)"
  end

  -- id / any
  local ts_query_setting = [[
    (field
      name: (identifier) @name (#eq? @name "debug")
      value: (false) @value (#eq? @value "false")
    )
  ]]

  -- local name = make_name()
  -- local value = make_value()
  -- local field = wrap("field", name .. value)

  -- str / tbl
  local ts_query_package = [[
    (field
      name: (string) @name (#eq? @name "\"nvim-cmp\"")
      value: (table_constructor
        ;(field
        ;  value: (string) @repo
        ;    (#eq? @repo "\"hrsh7th/nvim-cmp\"")
        ;)
      )
    )
  ]]

  return wrap(str, "field")
end

-- local assignment_statement = function()
--   local ts_query_others = [[
--     (assignment_statement
--       (variable_list
--         name:
--           ;(dot_index_expression
--           ;  table: (identifier)
--           ;  field: (identifier) @comp_tbl_name
--           ;  (#eq? @comp_tbl_name "%s")
--           ;)
--       )
--       (expression_list
--         value: (table_constructor) @comp_unit
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
-- end

-- local M.function = function()
-- end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

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

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

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
