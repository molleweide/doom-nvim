local utils = require("doom.utils")
local log = require("doom.utils.logging")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local _utils = require("doom.modules.core.nest.mapper.utils")

local M = {}

M.jump_to_binding = function(prompt_bufnr)
    local entry = action_state.get_selected_entry()

    local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)
    local binds_table, stack =
        require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(module_path, entry.keys)

    if stack then
        local last = stack[#stack]
        local lhs_prefix_range = { last.prefix:range() }
        actions.close(prompt_bufnr)
        vim.cmd(string.format("edit %s", module_path))
        vim.api.nvim_win_set_cursor(0, { lhs_prefix_range[1] + 1, lhs_prefix_range[2] + 1 })
        vim.cmd("norm zz")
    else
        -- TODO: If has binds table, then jump to the binds table.
        -- local buf = utils.get_buf_handle(module_path)
        -- local ts_utils_lua = require("doom.utils.ts.lua")
        -- local ts_buf = ts_utils_lua:new(buf)
        -- local t_nodes = ts_buf:query_wrap({
        --     query = require("doom.modules.core.nest.mapper.queries").binds_tables,
        --     capture = "binds.table",
        -- }, true)

        actions.close(prompt_bufnr)
        vim.cmd(string.format("edit %s", module_path))
    end
end

-- WARN: VALIDATE CHANGES BEFORE WRITING THEM TO FILE
--          ^ I need to check that new data is valid and wont fail
M.edit_binding_name = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local finder = current_picker.finder
    local entry = action_state.get_selected_entry()

    local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)
    local binds_table, bind_stack =
        require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(module_path, entry.keys)

    if not bind_stack then
        vim.notify("Couldnt find binding with TS")
        return
    end

    local leaf = bind_stack[#bind_stack]

    vim.ui.input({ prompt = "Rename: ", default = entry.description }, function(input)
        vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt

        PS("rename node: {{ %s }}", leaf.name:content())

        -- TODO: Ensure new name is unique and valid.

        -- leaf.name:content():replace(utils.escape_str(input))
    end)
end

-- WARN: VALIDATE CHANGES BEFORE WRITING THEM TO FILE
--          ^ I need to check that new data is valid and wont fail
M.edit_binding_rhs = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local finder = current_picker.finder
    local entry = action_state.get_selected_entry()

    local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)
    local binds_table, bind_stack =
        require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(module_path, entry.keys)

    if not bind_stack then
        vim.notify("Couldnt find binding with TS")
        return
    end

    local leaf = bind_stack[#bind_stack]

    if leaf.rhs:type() == "string" then
        vim.ui.input(
            { prompt = "Rename: ", default = tostring(leaf.rhs:content()) },
            function(input)
                vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt

                PS("Update RHS string node: {{ %s }}", leaf.name:content())

                -- leaf.name:content():replace(utils.escape_str(input))
            end
        )
    elseif leaf.rhs:type() == "function_definition" then
        vim.notify("Editing [RHS == functions] is not supported yet..")
        -- TODO: throw up popup buffer.
    elseif leaf.rhs:type() == "identifier" then
        vim.notify("Editing [RHS == identifier] is not supported yet..")
    end
end

-- TODO: ADD NEW [normal] BIND W/ DUMMY RHS ACTION
-- ~~ ( ) If no selection, add to [config.lua]
-- ~~ ( ) Else, add to selected module.
M.add_new_dummy_bind = function(prompt_bufnr)
    vim.ui.input({ prompt = "New LHS: " }, function(input)
        -- vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt

        print("ADD NEW BIND")

        local entry = action_state.get_selected_entry()

        local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)

        local binds_table, leaf_stack, insertion_table, buf =
            require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(module_path, input)

        if leaf_stack then
            print("LEAF", leaf_stack[#leaf_stack])
        end

        print("INSERTION TABLE:", insertion_table)

        local dummy_bind = {
            { "QA", ':echo "hello"', name = "v2 dummy mapping" },
            -- { "QB", ':echo "hello"', name = "v2 dummy mapping" },
        }

        local t_dummy_bind_inject = utils.build_new_inject_string(dummy_bind)

        -- P(t_dummy_bind_inject)

        for _, s in ipairs(t_dummy_bind_inject) do
            print()
            PS("::: %s", s)
        end

        -- Binds table exists and we found a insertion table for injecting our
        -- new binds data into.
        if insertion_table then
            PS("final insertion: \n<%s>", t_dummy_bind_inject)
            insertion_table:add_field({
                pos = "last",
                data = t_dummy_bind_inject,
            })
        else
            -- Now insertion_table implies that there is no binds table in the module.

            -- If config.lua, simply insert new contents last.
            if module_path == require("doom.core.config").source then
                table.insert(t_dummy_bind_inject, 1, "doom.use_keybind({")
                table.insert(t_dummy_bind_inject, "})")
                -- vim.api.nvim_buf_set_lines(buf, -1, -1, false, t_dummy_bind_inject)
                PS("final insertion: \n<%s>", t_dummy_bind_inject)
            else
                -- TODO: ( ) get the return statement, check the name of the module,
                -- then pre/append the necessary M.binds = {} table bootstrapping.
                -- ~ use the add_contents_above method to inject data above the
                -- return statement.

                local ts_utils_lua = require("doom.utils.ts.lua")
                local ts_buf = ts_utils_lua:new(buf)

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
                    t_dummy_bind_inject,
                    1,
                    string.format("%s.binds = {", tostring(ts_module_identifier))
                )
                table.insert(t_dummy_bind_inject, "}")
                PS("final insertion: \n<%s>", t_dummy_bind_inject)
            end
        end

        -- TODO: run formatting on file
    end)
end

M.select_filter_modes = function(prompt_bufnr) end

M.move_selected_binds_to_module = function(prompt_bufnr) end

-- TODO: toggle `:h index`, and external mappigs that comes from `:mapargs`
M.select_filter_mappings = function(prompt_bufnr) end

return M
