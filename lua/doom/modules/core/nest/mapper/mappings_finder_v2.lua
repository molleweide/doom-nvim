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

---1. Tries to find the definition table of a binding in a [binds] table.
---Expects a wrapped [binds] table_constructor as input node.
---2. Currently, return the wrapped table node of the definiton table if found.
---3. (Later), return parent, or whatever, so that one can manage the leader
---branches.
M.bind_finder = function(start_table_node, cb_leaf, cb_branch)
    print([[
-------------------------------------------------------
-- BIND_FINDER ----------------------------------------
-------------------------------------------------------
    ]])

    local leaf_predicate = false
    local settings_stack = {}

    local function traverse(tbl_node)
        -- FIX: In the regular traverse, this is always deepcopied, so that
        -- subsequent calls dont affect siblings. However, we cant use deepcopy
        -- here, since, <userdata> throws error. >>> Need to maintain a stack
        -- manually.
        --
        --
        -- local mergedSettings = mergeSettings(settings or module.defaults, node)

        local first, prefix, lhs, rhs, name, description
        local node = {}

        -- NOTE: in original, then prefix is a string, but now it is a node, so we
        -- need to use a list instead of a string.

        first = tbl_node:dict(1).value

        ----------------------
        -- A. handle iter top-level

        if first:type() == "table_constructor" then
            for _, tbl_child in tbl_node:iter_fields("indexed") do
                print(string.format("TRAVERS INTO: <%s>", tbl_child))
                traverse(tbl_child)
                if leaf_predicate then
                    return
                end
                table.remove(settings_stack)
            end
            return
        end

        ----------------------
        -- B. leaf or named leader branch

        prefix = first

        local current_settings = { prefix = prefix }

        table.insert(settings_stack, current_settings)

        rhs = tbl_node:dict(2).value

        -- NOTE: This is a bit annoying. if it returns nil, then we can check for
        -- the valuez.

        if tbl_node:dict("name") then
            current_settings.name = tbl_node:dict("name").value
        elseif tbl_node:dict("name") == nil and tbl_node.length >= 3 then
            current_settings.name = tbl_node:dict(3).value
        end

        if tbl_node:dict("description") then
            current_settings.description = tbl_node:dict("description").value
        elseif tbl_node:dict("description") == nil and tbl_node.length >= 4 then
            current_settings.description = tbl_node:dict(4).value
        end

        if tbl_node:dict("options") then
            current_settings.options = tbl_node:dict("options").value
        end

        -- lhs
        current_settings.lhs = current_settings.prefix
        current_settings.rhs = rhs

        if cb_branch and type(cb_branch) == "function" then
            if cb_branch(settings_stack) then
                return
            end
        end

        if rhs:type() == "table_constructor" then
            traverse(rhs)
        else
            if cb_leaf and type(cb_leaf) == "function" then
                if cb_leaf(settings_stack) then
                    leaf_predicate = true
                end
            end
        end
    end

    traverse(start_table_node)
end

M.v2 = function(entry)
    local utils = require("doom.utils")
    local _utils = require("doom.modules.core.nest.mapper.utils")
    local ts_utils_lua = require("doom.utils.ts.lua")
    local keys_parsed = _utils.parse_key_sequence(entry.keys)
    local module_path = _utils.get_abs_path_from_module_origin(entry)

    local buf = utils.get_buf_handle(module_path)
    local ts_buf = ts_utils_lua:new(buf)

    print("ENTRY ENTRY FROM V2:", vim.inspect(entry))

    print("FROM V2 FROM PWEVIEWER:", vim.inspect(keys_parsed))

    local t_nodes = ts_buf:query_wrap({ query = ts_query, capture = "binds.table" }, true)

    -- print("CAPTURES:", vim.inspect(t_nodes))

    local ret = {}

    for _, n in ipairs(t_nodes) do
        M.bind_finder(n, function(stack)
            local found = false
            local last = stack[#stack]

            local lhs_concat = table.concat(vim.iter(stack)
                :map(function(v)
                    return tostring(v.prefix:content())
                end)
                :totable())

            PS(
                [[
        --- CHECK LEAF ---
        prefix: {{ %s }}
        name:   {{ %s }}
        lhs:    {{ %s }}
]],
                last.prefix,
                last.name,
                lhs_concat
            )

            -- TODO: (x) return a proper stack
            -- (*) compare stack against [keys_parsed]; return bool
            --      ^ The concatenated lhs, and keys are strings, in the standard
            --          case, so I should just do an equals comparison.
            -- ( ) If lhs contains non string node
            --      ~ Inform user "cannot parse due to `LHS contains non-string-node"
            --      ~ Collect this diagnostics in table and show in previewer.
            --          ^ "Potential match, but requires not-yet-supported analysis."

            if lhs_concat == entry.keys then
                found = true
                ret.definition_stack = stack
                PS("Found mapping definition: %s", lhs_concat)
            end

            return found
        end)
        break
    end

    -- print("#ret", #ret.definition_stack)

    return ret
end

return M
