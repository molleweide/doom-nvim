local M = {}

-- NOTE: Resources:
-- ~ :map-verbose
-- ~ builtin maparg()
-- ~ nvim_set_keymap()
-- ~ maparg()
-- ~ mapcheck()
-- ~ mapset()
-- ~ vim.fn.maplist
-- ~ https://www.reddit.com/r/vim/comments/x1zll/command_to_get_lhs_of_a_mapping/

-- TODO: ( ) Make a query that captures each of:
-- ~ table enclosed in [use_keybinds(\{...})] in [config.lua]
-- ~ [binds = \{...}]
--    ~~ in modules with [M.binds = ...]
--    ~~ in config.lua with [local binds = ...]
-- TEST: Later, I can check for more dynamically put together components.

M.v2 = function(args)
    local utils = require("doom.utils")

    -- TODO: Make queries | These are the first level of table_constructor's to query for
    -- `M.bind = ...`
    --      (assignment_statement ; [233, 0] - [260, 1]
    --        (variable_list ; [233, 0] - [233, 10]
    --          name: (dot_index_expression ; [233, 0] - [233, 10]
    --            table: (identifier) ; [233, 0] - [233, 4]
    --            field: (identifier))) ; [233, 5] - [233, 10]
    --        (expression_list ; [233, 13] - [260, 1]
    --          value: (table_constructor ; [233, 13] - [260, 1]
    -- `M.bind = function() ...`
    --      (assignment_statement ; [140, 0] - [284, 3]
    --        (variable_list ; [140, 0] - [140, 15]
    --          name: (dot_index_expression ; [140, 0] - [140, 15]
    --            table: (identifier) ; [140, 0] - [140, 9]
    --            field: (identifier))) ; [140, 10] - [140, 15]
    --        (expression_list ; [140, 18] - [284, 3]
    --          value: (function_definition ; [140, 18] - [284, 3]
    --            parameters: (parameters) ; [140, 26] - [140, 28]
    --            body: (block ; [141, 4] - [283, 16]
    -- `doom.use_keybind({...})`
    --      (function_call ; [738, 0] - [752, 2]
    --        name: (dot_index_expression ; [738, 0] - [738, 16]
    --          table: (identifier) ; [738, 0] - [738, 4]
    --          field: (identifier)) ; [738, 5] - [738, 16]
    --        arguments: (arguments ; [738, 16] - [752, 2]
    --          (table_constructor ; [738, 17] - [752, 1]

    -- TODO: Get ts buf of path (copy from mod manager)
    --  redo this staement with the module path.

    -- local buf = utils.get_buf_handle(utils.find_config("modules.lua"))

    -- TODO: Go to file (copy from mod manager.)
    -- utils.edit_file_in_window(v.new:path(), "current")

    -- TODO: Mirror [services/keymaps]



end

return M
