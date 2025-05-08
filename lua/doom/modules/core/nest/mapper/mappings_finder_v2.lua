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
local ts_query = [[
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

M.v2 = function(entry)
    local utils = require("doom.utils")
    local _utils = require("doom.modules.core.nest.mapper.utils")
    local ts_utils_lua = require("doom.utils.ts.lua")
    local keys_parsed = _utils.parse_key_sequence(entry.keys)
    local module_path = _utils.get_abs_path_from_module_origin(entry)
    local buf = utils.get_buf_handle(module_path)
    local ts_buf = ts_utils_lua:new(buf)

    print("from v2 from pweviewer:", vim.inspect(keys_parsed))

    -- TODO: ( ) print the bindings tree if found. `h iter_captures`
    -- ~ check that i have a good query func for getting captures.
    --      ^ It has to work with [config.lua] where there can be multiple tables.
    --      --
    -- ~ I need to be able to return multiple captures.
    -- ~ Specify which captures I want.
    --      ^ I only want [@binds.table]

    local node = ts_buf:query_wrap(ts_query, true)

    print("NODE:", node)

    return node

    -- TODO: Mirror [services/keymaps]

    -- local function prepare_args(keybind)
    --     return {
    --         module_path = _utils.get_abs_path_from_module_origin(keybind),
    --         keybind = keybind,
    --         keys_parsed = _utils.parse_key_sequence(keybind.keys),
    --     }
    -- end
end

return M
