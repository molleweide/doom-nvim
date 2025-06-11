local utils = require("doom.utils")
local log = require("doom.utils.logging")

local _utils = require("doom.modules.core.nest.mapper.utils")

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

local function table_remove_n(t, n)
    for i = 1, n, 1 do
        table.remove(t, 1)
    end
end

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
---@param input_start_node userdata The binds table to target
---@param input_lhs_string string The string used to match from
---@param cb_leaf? function
---@param cb_branch? function
M.bind_finder = function(
    input_start_node,
    input_lhs_string,
    input_lhs_parsed,
    callback_leaf,
    callback_branch
)
    print([[
-------------------------------------------------------
-- BIND_FINDER ----------------------------------------
-------------------------------------------------------
    ]])

    local function compare_node_to_input() end

    -- local leaf_predicate = false -- used with callbacks at the bottom.
    local branch_stack = {}
    local parent_table
    local insertion_level_highest_so_far = 0
    local insertion_point_data
    local target_leaf_stack

    ---@param ts_table_node userdata The table we currently are operating on
    ---@param current_lhs_string string Input sequence that is trimmed from the start if there is a prefix match
    ---@param _lhs_parsed table The parsed_keys table of the lhs_input_seq, that is also trimmed from 1
    ---@param lhs_real_accumulated string Builds the current real sequence that we find with treesitter.
    local function traverse(
        ts_table_node,
        current_lhs_string,
        _lhs_parsed,
        lhs_real_accumulated,
        insertion_level
    )
        local lhs_parsed = vim.deepcopy(_lhs_parsed)

        local first = ts_table_node:dict(1).value

        -- top level
        if first:type() == "table_constructor" then
            parent_table = ts_table_node

            for _, tbl_child in ts_table_node:iter_fields("indexed") do
                -- print(string.format("TRAVERS INTO: <%s>", tbl_child))
                traverse(
                    tbl_child,
                    current_lhs_string,
                    lhs_parsed,
                    lhs_real_accumulated,
                    insertion_level
                )
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

        local rhs = ts_table_node:dict(2).value

        -- NOTE: This is a bit annoying. if it returns nil, then we can check for
        -- the valuez.

        if ts_table_node:dict("name") then
            current_settings.name = ts_table_node:dict("name").value
        elseif ts_table_node:dict("name") == nil and ts_table_node.length >= 3 then
            current_settings.name = ts_table_node:dict(3).value
        end

        if ts_table_node:dict("description") then
            current_settings.description = ts_table_node:dict("description").value
        elseif ts_table_node:dict("description") == nil and ts_table_node.length >= 4 then
            current_settings.description = ts_table_node:dict(4).value
        end

        if ts_table_node:dict("options") then
            current_settings.options = ts_table_node:dict("options").value
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

        lhs_real_accumulated = lhs_real_accumulated .. prefix_content

        local prefix_content_escaped = utils.escape_str(prefix_content)
        local sub_left, sub_right = ""

        -- this block makes it so that a
        local next_ins_level
        local s, e = current_lhs_string:find("^" .. prefix_content_escaped)

        -- NOTE: Scrap, this impl of prefix matching the input sequence with the
        -- current prefix, and instead just use the input_parsed_copy table.
        -- 1. This would make it so that all mappings are managed as nested tables
        -- with a single char per level, but i think this is fine for now, since,
        -- it makes it much easier to deal with.

        -- found match!
        if s and e then
            sub_left = current_lhs_string:sub(s, e)
            sub_right = current_lhs_string:sub(e + 1)
            if #sub_right > 0 then
                next_ins_level = insertion_level + 1

                local sub_left_parsed = _utils.parse_key_sequence(sub_left)
                table_remove_n(lhs_parsed, #sub_left_parsed)

                -- if we are at a deeper level of nesting, then update the insertion point
                if next_ins_level > insertion_level_highest_so_far then
                    insertion_level_highest_so_far = next_ins_level

                    insertion_point_data = {
                        keys_parsed_leftover = lhs_parsed,
                        trimmed_count = #input_lhs_parsed - #lhs_parsed,
                        ts_target_table = parent_table,
                    }
                end
            end
        else
            next_ins_level = insertion_level

            -- NOTE: should it be <= ins_level_highest here so that we dont
            -- update the insertion point with a lower level?!

            if sub_right == nil and next_ins_level == insertion_level_highest_so_far then
                insertion_point_data = {
                    keys_parsed_leftover = lhs_parsed,
                    trimmed_count = #input_lhs_parsed - #lhs_parsed,
                    ts_target_table = parent_table,
                }
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
            traverse(rhs, sub_right or "", lhs_parsed, lhs_real_accumulated, next_ins_level)
        else
            -- the input string matches with the accumulated string which means
            -- that we have a matching leaf.
            if input_lhs_string == lhs_real_accumulated then
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

    traverse(input_start_node, input_lhs_string, input_lhs_parsed, "", 0)

    -- could this be set first?
    if not insertion_point_data then
        print(">>> Insertion was nil, so setting it now at the end...")({
            keys_parsed_leftover = lhs_parsed,
            ts_target_table = parent_table,
        })

        insertion_point_data = {
            keys_parsed_leftover = input_lhs_parsed,
            trimmed_count = 0,
            ts_target_table = input_start_node,
        }
    end

    if target_leaf_stack then
        insertion_point_data = nil
    end

    log.debug(
        string.format(
            [[ Target leaf: %s; Injection table: %s ]],
            target_leaf_stack and true or false,
            insertion_point_data and true or false
        )
    )

    if target_leaf_stack then
        local leaf_prefix = target_leaf_stack[#target_leaf_stack].prefix

        print("target leaf:", target_leaf_stack and leaf_prefix((leaf_prefix):parent():parent()))
    else
        print("target leaf:", nil)
    end

    return target_leaf_stack, insertion_point_data
end

M.v2 = function(target_path, target_keys)
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

    local target_leaf_stack, insertion_data

    local binds_table_constructor = t_nodes[1]

    -- PS("binds_table_constructor -> <<%s>>", binds_table_constructor)

    -- for _, binds_table_constructor in ipairs(t_nodes) do
    if binds_table_constructor then
        target_leaf_stack, insertion_data =
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

    return binds_table_constructor, target_leaf_stack, insertion_data, buf
end

M.build_new_mappings_tree = function()
    local t_new_bind_lua = build_mapping_branch()
    local t_new_bind_lua_stringified = utils.build_new_inject_string(t_new_bind_lua, true)

    PS("t_new_bind_lua: <%s>", vim.inspect(t_new_bind_lua))

    PS("t_new_bind_lua_stringified: <%s>", vim.inspect(t_new_bind_lua_stringified))

    -- TODO: Move this logic of merging a function into another table.

    if rhs_is_func then
        local fn_pattern = '"<FUNCTION>"'
        for i, v in ipairs(t_new_bind_lua_stringified) do
            PS("%s t_new_bind_lua_stringified | %s", i, v)

            local match = v:match(fn_pattern)

            if match then
                local mi = i -- match index
                local ms, me = v:find(fn_pattern)
                local current_value = v

                local fn_split_pre = current_value:sub(1, ms)
                local fn_split_post = current_value:sub(me)

                t_new_bind_lua_stringified[i] = fn_split_pre .. "function()"

                for j, w in ipairs(user_input_rhs_contents) do
                    table.insert(t_new_bind_lua_stringified, i + j, w)
                end

                table.insert(
                    t_new_bind_lua_stringified,
                    i + #user_input_rhs_contents,
                    "end" .. fn_split_post
                )
            end
        end

        for i, v in ipairs(t_new_bind_lua_stringified) do
            PS("%s t_new_bind_lua_stringified AFTER | %s", i, v)
        end
    end
end

M.insert_new_binds_tree = function()
    -- Binds table exists and we found a insertion table for injecting our
    -- new binds data into.
    if insertion_data.ts_target_table then
        PS("final insertion: \n<%s>", t_new_bind_lua_stringified)
        -- insertion_data.ts_target_table:add_field({
        --     pos = "last",
        --     data = t_new_bind_lua_stringified,
        -- })
    else
        -- Now insertion_data.ts_target_table implies that there is no binds table in the module.

        -- If config.lua, simply insert new contents last.
        if module_path == require("doom.core.config").source then
            table.insert(t_new_bind_lua_stringified, 1, "doom.use_keybind({")
            table.insert(t_new_bind_lua_stringified, "})")

            -- vim.api.nvim_buf_set_lines(buf, -1, -1, false, t_new_bind_lua_stringified)

            PS("final insertion: \n<%s>", t_new_bind_lua_stringified)
        else
            -- TODO: ( ) get the return statement, check the name of the module,
            -- then pre/append the necessary M.binds = {} table bootstrapping.
            -- ~ use the add_contents_above method to inject data above the
            -- return statement.

            local ts_utils_lua = require("doom.utils.ts.lua")
            local ts_buf = ts_utils_lua:new(target_buf)

            local ts_query_module_return = [[
                    (chunk (return_statement (expression_list (identifier) @module.identifier)))
                ]]

            local ts_module_identifier = ts_buf:query_wrap({
                query = ts_query_module_return,
                capture = "module.identifier",
            }, true)[1]

            if not ts_module_identifier then
                log.warn(
                    "Aborting! Could not find a return statement for module:",
                    entry.module_origin
                )
                return
            end

            table.insert(
                t_new_bind_lua_stringified,
                1,
                string.format("%s.binds = {", tostring(ts_module_identifier))
            )
            table.insert(t_new_bind_lua_stringified, "}")
            PS("final insertion: \n<%s>", t_new_bind_lua_stringified)
        end
    end
end

return M
