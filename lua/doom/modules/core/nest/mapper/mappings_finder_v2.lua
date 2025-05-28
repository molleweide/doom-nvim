local utils = require("doom.utils")
local log = require("doom.utils.logging")

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
-- NOTE: A partial key can consist of two components. This is assumed.
-- Ie. only two parts, eg. `<C-` and `c>`, and not three distinct parts.
--
-- WARN: Handle `partial` modifier keys, eg `<C-` as a lhs.
--      ^ Solution: A parent injection branch cannot end with `<%W-`

---1. Tries to find the definition table of a binding in a [binds] table.
---Expects a wrapped [binds] table_constructor as input node.
---2. Currently, return the wrapped table node of the definiton table if found.
---3. (Later), return parent, or whatever, so that one can manage the leader
---branches.

---Get information about LHS on specifc binds tree. Returns the branch sequence
---of TS nodes up until the last segment found.
---If there is a full match for a key sequence, then the leaf_stack is returned
---in the first return value, and if there is a partial or no match, then the
---proposed insertion point table for this potentially new mapping is returned.
---It tries to return the insertion point table at the most granular point, ie.
---a table branch with each lhs prefix being the smallest size, eg. "g", "c", "c"
---wins over "gc" prefix.
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

    -- local leaf_predicate = false -- used with callbacks at the bottom.
    local branch_stack = {}
    local parent_table
    local ins_level_highest = 0
    local insertion_branch_for_lhs_input
    local target_leaf_stack

    ---@param tbl_node userdata The table we currently are operating on
    ---@param input_seq string Input sequence that is trimmed from the start if there is a prefix match
    ---@param input_parsed table The parsed_keys table of the lhs_input_seq, that is also trimmed from 1
    ---@param seq_accumulated string Builds the current real sequence that we find with treesitter.
    local function traverse(tbl_node, input_seq, input_parsed, seq_accumulated, ins_level)
        local input_parsed_copy = vim.deepcopy(input_parsed)

        local first = tbl_node:dict(1).value

        -- top level
        if first:type() == "table_constructor" then
            parent_table = tbl_node

            for _, tbl_child in tbl_node:iter_fields("indexed") do
                -- print(string.format("TRAVERS INTO: <%s>", tbl_child))
                traverse(tbl_child, input_seq, input_parsed, seq_accumulated, ins_level)
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

        -- partial keys: unsuported for now.
        local is_partial_start = prefix_content:match("<%a%-$") -- a prefix ends with partial key
        if is_partial_start then
            return
        end

        seq_accumulated = seq_accumulated .. prefix_content

        local prefix_content_escaped = utils.escape_str(prefix_content)
        local sub_left, sub_right

        -- this block makes it so that a
        local next_ins_level
        local s, e = input_seq:find("^" .. prefix_content_escaped)
        if s and e then
            sub_left = input_seq:sub(s, e)
            sub_right = input_seq:sub(e + 1)
            if #sub_right > 0 then
                next_ins_level = ins_level + 1
                if next_ins_level > ins_level_highest then
                    ins_level_highest = next_ins_level
                    insertion_branch_for_lhs_input = parent_table
                end
            end
        else
            next_ins_level = ins_level
            if sub_right == nil and next_ins_level == ins_level_highest then
                insertion_branch_for_lhs_input = parent_table
            end
        end

        --         PS(
        --             [[
        -- ::: ^find against input seq :::
        -- real_sequence:  %s
        -- input_seq:      %s
        -- prefix:         %s
        -- pattern:        %s
        -- s,e:            %s, %s
        -- substr:         %s
        -- leftover:       %s
        -- lhs_input_seq == seq_accumulated: %s, %s
        --         ]],
        --             seq_accumulated,
        --             input_seq,
        --             prefix,
        --             "^" .. prefix_content_escaped,
        --             s,
        --             e,
        --             sub_left,
        --             sub_right,
        --             lhs_input_seq,
        --             seq_accumulated
        --         )

        if rhs:type() == "table_constructor" then
            -- if cb_branch and type(cb_branch) == "function" then
            --     if cb_branch(branch_stack) then
            --         return
            --     end
            -- end
            traverse(rhs, sub_right or "", input_parsed, seq_accumulated, next_ins_level)
        else
            -- the input string matches with the accumulated string which means
            -- that we have a matching leaf.
            if lhs_input_seq == seq_accumulated then
                -- NOTE: manually copy the target leaf table stack to the return value,
                -- as the recursor will continue to
                -- TEST: I should be able to simply return here, and then I can
                -- just assign target_leaf_stack = branch_stack, but I have to
                -- investigate that something else doesnt depend on the recursin
                -- to complete fully first.
                local res = {}
                for i, v in ipairs(branch_stack) do
                    table.insert(res, {})
                    for j, w in pairs(v) do
                        print(j, w)
                        res[i][j] = w
                    end
                end
                target_leaf_stack = res
            end

            -- if cb_leaf and type(cb_leaf) == "function" then
            --     if cb_leaf(branch_stack) then
            --         leaf_predicate = true
            --     end
            -- end
        end
    end

    traverse(start_table_node, lhs_input_seq, lhs_parsed, "", 0)

    -- could this be set first?
    if not insertion_branch_for_lhs_input then
        print(">>> Insertion was nil, so setting it now at the end...")
        insertion_branch_for_lhs_input = start_table_node
    end

    if target_leaf_stack then
        insertion_branch_for_lhs_input = nil
    end

    log.debug(
        string.format(
            [[ Target leaf: %s; Injection table: %s ]],
            target_leaf_stack and true or false,
            insertion_branch_for_lhs_input and true or false
        )
    )

    if target_leaf_stack then

        local leaf_prefix = target_leaf_stack[#target_leaf_stack].prefix

        print(
            "target leaf:",
            target_leaf_stack and leaf_prefix((leaf_prefix):parent():parent())
        )
    else
        print("target leaf:", nil)
    end

    return target_leaf_stack, insertion_branch_for_lhs_input
end

M.v2 = function(target_path, target_keys)
    local _utils = require("doom.modules.core.nest.mapper.utils")
    local ts_utils_lua = require("doom.utils.ts.lua")

    print("keys is null:", target_keys)

    local keys_parsed = _utils.parse_key_sequence(target_keys)

    -- print("ENTRY ENTRY FROM V2:", vim.inspect(entry))

    -- log.info(vim.inspect(keys_parsed))

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

    -- PS("binds_table_constructor -> <<%s>>", binds_table_constructor)

    -- for _, binds_table_constructor in ipairs(t_nodes) do
    if binds_table_constructor then
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

    return binds_table_constructor, target_leaf_stack, insertion_branch, buf
end

return M
