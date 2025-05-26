local utils = require("doom.utils")

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

-- local ts_query = [[
--     ; NOTE: How can I reduce these queries to be smaller
--     ;`M.bind = ...`
--          (assignment_statement
--            (variable_list
--              name: (dot_index_expression
--                table: (identifier)
--                field: (identifier) @field
--                   (#lua-match? @field "binds")
--                 ))
--            (expression_list
--              value: (table_constructor) @binds.table))
--
--     ;;`M.bind = function() ...`
--          (assignment_statement
--            (variable_list
--              name: (dot_index_expression
--                table: (identifier)
--                field: (identifier) @field
--                   (#lua-match? @field "binds")
--                 ))
--            (expression_list
--              value: (function_definition
--                parameters: (parameters)
--                body: (block) @binds.func_body)))
--
--     ;;`doom.use_keybind({...})`
--          (function_call
--            name: (dot_index_expression
--              table: (identifier)
--              field: (identifier) @field
--               (#lua-match? @field "use_keybind")
--             )
--            arguments: (arguments
--              (table_constructor) @binds.table))
-- ]]

---1. Tries to find the definition table of a binding in a [binds] table.
---Expects a wrapped [binds] table_constructor as input node.
---2. Currently, return the wrapped table node of the definiton table if found.
---3. (Later), return parent, or whatever, so that one can manage the leader
---branches.
---
---Get information about LHS on specifc binds tree. Returns the branch sequence
---of TS nodes up until the last segment found.
---
---@param start_table_node userdata The binds table to target
---@param lhs_input_seq string The string used to match from
---@param cb_leaf? function
---@param cb_branch? function
M.bind_finder = function(start_table_node, lhs_input_seq, lhs_parsed, cb_leaf, cb_branch)
    print([[
-------------------------------------------------------
-- BIND_FINDER ----------------------------------------
-------------------------------------------------------
    ]])

    -- TODO: Pass target_keys and then do iterative pattern matching.
    --      ~ pass string
    --      ~ for each level check if the current node lhs segment matches
    --              target_keys:find("^lhs_segment")
    --      ~ remove the found substring when entering child
    --
    -- TODO: Always check that a branch does not have a `mode = X` statement
    -- that cascades a branch. Ie. ensure that we are always check on the
    -- correct branch AND mode.
    --
    -- WARN: Handle `partial` modifier keys, eg `<C-` as a lhs.
    --      ^ Solution: A parent injection branch cannot end with `<%W-`

    local leaf_predicate = false
    local branch_stack = {}
    local parent_table
    local insertion_branch_for_lhs_input
    local target_leaf_stack

    local function traverse(tbl_node, input_seq, input_parsed, seq_accumulated)
        local input_parsed_copy = vim.deepcopy(input_parsed)
        -- FIX: In the regular traverse, this is always deepcopied, so that
        -- subsequent calls dont affect siblings. However, we cant use deepcopy
        -- here, since, <userdata> throws error. >>> Need to maintain a stack
        -- manually.
        --
        --
        -- local mergedSettings = mergeSettings(settings or module.defaults, node)

        local first = tbl_node:dict(1).value

        -- top level
        if first:type() == "table_constructor" then
            parent_table = tbl_node

            print("?")

            for _, tbl_child in tbl_node:iter_fields("indexed") do
                print(string.format("TRAVERS INTO: <%s>", tbl_child))
                traverse(tbl_child, input_seq, input_parsed, seq_accumulated)
                -- if leaf_predicate then
                --     return
                -- end

                -- if the leaf stack has been found, then stop modifying it.
                if not target_leaf_stack then
                    table.remove(branch_stack)
                end
            end
            return
        end

        -- branch or leaf

        local prefix = first

        -- Return early for unsupported node types, eg if lhs is a reference.
        if prefix:type() == "dot_index_expression" then
            return
        end

        local current_settings = { prefix = prefix }
        table.insert(branch_stack, current_settings)

        local rhs = tbl_node:dict(2).value

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

        -- do ^find and substring here.

        local prefix_content = tostring(prefix:content())

        seq_accumulated = seq_accumulated .. prefix_content

        local prefix_content_escaped = utils.escape_str(prefix_content)
        local sub_left, sub_left

        if input_seq then
            local s, e = input_seq:find("^" .. prefix_content_escaped)
            local has_match

            if s and e then
                has_match = true
                sub_left = input_seq:sub(s, e)
                sub_right = input_seq:sub(e + 1)

                if sub_right == "" then
                    insertion_branch_for_lhs_input = parent_table
                end
            end

            PS(
                [[
::: ^find against input seq :::
real_sequence:  %s
input_seq:      %s
prefix:         %s
pattern:        %s
s,e:            %s, %s
substr:         %s
leftover:       %s
        ]],
                seq_accumulated,
                input_seq,
                prefix,
                "^" .. prefix_content_escaped,
                s,
                e,
                sub_left,
                sub_right
            )
        else
            print("v2: INPUT SEQ == NIL")
        end

        PS("??? %s == %s ===", lhs_input_seq, seq_accumulated)

        if rhs:type() == "table_constructor" then
            -- if cb_branch and type(cb_branch) == "function" then
            --     if cb_branch(branch_stack) then
            --         return
            --     end
            -- end
            traverse(rhs, sub_right, input_parsed, seq_accumulated)
        else
            -- the input string matches with the accumulated string which means
            -- that we have a matching leaf.
            if lhs_input_seq == seq_accumulated then
                print("<<< !!!!!!!!!!!!!! >>>")
                target_leaf_stack = branch_stack
            end

            -- if cb_leaf and type(cb_leaf) == "function" then
            --     if cb_leaf(branch_stack) then
            --         leaf_predicate = true
            --     end
            -- end
        end
    end

    traverse(start_table_node, lhs_input_seq, lhs_parsed, "")

    -- PS("target leaf: <<%s>>", vim.inspect(target_leaf_stack))
    PS("target leaf: <<%s>>", target_leaf_stack and target_leaf_stack[#target_leaf_stack])
    PS("insertion table: <<%s>>", insertion_branch_for_lhs_input)

    if not insertion_branch_for_lhs_input then
        insertion_branch_for_lhs_input = start_table_node
    end

    print(">>", target_leaf_stack, insertion_branch_for_lhs_input)

    return target_leaf_stack, insertion_branch_for_lhs_input
end

M.v2 = function(target_path, target_keys)
    local _utils = require("doom.modules.core.nest.mapper.utils")
    local ts_utils_lua = require("doom.utils.ts.lua")

    print("keys is null:", target_keys)

    local keys_parsed = _utils.parse_key_sequence(target_keys)

    -- print("ENTRY ENTRY FROM V2:", vim.inspect(entry))

    print("FROM V2 FROM PWEVIEWER:", vim.inspect(keys_parsed))

    local buf = utils.get_buf_handle(target_path)
    local ts_buf = ts_utils_lua:new(buf)

    local t_nodes = ts_buf:query_wrap({
        query = require("doom.modules.core.nest.mapper.queries").binds_tables,
        capture = "binds.table",
    }, true)

    -- print("CAPTURES:", vim.inspect(t_nodes))

    local ret = {}

    local target_leaf_stack, insertion_branch

    local binds_table_constructor = t_nodes[1]

    print("XXX")

    PS("binds_table_constructor -> <<%s>>", binds_table_constructor)

    -- for _, binds_table_constructor in ipairs(t_nodes) do
    if binds_table_constructor then
        print("??????? ? ?")
        target_leaf_stack, insertion_branch =
            M.bind_finder(binds_table_constructor, target_keys, keys_parsed)

        --         target_leaf_stack, insertion_branch = M.bind_finder(
        --             binds_table_constructor,
        --             target_keys,
        --             function(stack)
        --                 local found = false
        --                 local last = stack[#stack]
        --
        --                 local lhs_concat = table.concat(vim.iter(stack)
        --                     :map(function(v)
        --                         return tostring(v.prefix:content())
        --                     end)
        --                     :totable())
        --
        --                 PS(
        --                     [[
        --         --- CHECK LEAF ---
        --         prefix: {{ %s }}
        --         name:   {{ %s }}
        --         lhs:    {{ %s }}
        -- ]],
        --                     last.prefix,
        --                     last.name,
        --                     lhs_concat
        --                 )
        --
        --                 -- TODO: (x) return a proper stack
        --                 -- (*) compare stack against [keys_parsed]; return bool
        --                 --      ^ The concatenated lhs, and keys are strings, in the standard
        --                 --          case, so I should just do an equals comparison.
        --                 -- ( ) If lhs contains non string node
        --                 --      ~ Inform user "cannot parse due to `LHS contains non-string-node"
        --                 --      ~ Collect this diagnostics in table and show in previewer.
        --                 --          ^ "Potential match, but requires not-yet-supported analysis."
        --
        --                 if lhs_concat == target_keys then
        --                     found = true
        --                     ret.definition_stack = stack
        --                     PS("Found mapping definition: %s", lhs_concat)
        --                 end
        --
        --                 return found
        --             end
        --         )
        -- break
    end

    -- print("#ret", #ret.definition_stack)

    return ret, target_leaf_stack, insertion_branch
end

return M
