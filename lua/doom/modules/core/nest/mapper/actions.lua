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
    -- TEST: Run this at the end if any issues with lingering ui components.
    -- vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt

    local entry = action_state.get_selected_entry()
    local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)

    local user_input_name, user_input_lhs, user_input_rhs_contents
    local rhs_is_func, leader_branch_names, new_lhs_parsed

    -- return values from v2 mappings finder parser.
    local insertion_data, target_buf

    local function prepare_rhs()
        if type(user_input_rhs_contents) == "function" then
            return "<FUNCTION>"
        end
        return user_input_rhs_contents
    end

    ---Puts together the mapping branch lua table, that will later be converted
    ---to a string for injection into the buffer.
    local function build_mapping_branch()
        local t_new_bind = {}
        local current
        for i, v in ipairs(new_lhs_parsed) do
            current = i == 1 and t_new_bind or current[2]
            current[1] = v
            current[2] = {}
            if i == #new_lhs_parsed then
                current[2] = prepare_rhs()
                current.name = user_input_name
            else
                if v:match("<leader>") then
                    current.name = "+prefix"
                elseif leader_branch_names and leader_branch_names[i] then
                    current.name = "+" .. leader_branch_names[i]
                end
            end
        end
        return t_new_bind
    end

    local function build_new_mapping()
        local dummy_bind = {
            { "QA", ':echo "hello"', name = "v2 dummy mapping" },
            -- { "QB", ':echo "hello"', name = "v2 dummy mapping" },
        }

        local t_new_bind = build_mapping_branch()

        PS("NEW BIND TABLE: <%s>", vim.inspect(t_new_bind))

        local t_dummy_bind_inject = utils.build_new_inject_string(dummy_bind)

        if rhs_is_func then
            print(":: TODO: REPLACE <FUNCTION> INTO INJECTION TABLE HERE ::")
        end

        -- P(t_dummy_bind_inject)

        for _, s in ipairs(t_dummy_bind_inject) do
            print()
            PS("::: %s", s)
        end

        -- Binds table exists and we found a insertion table for injecting our
        -- new binds data into.
        if insertion_table then
            PS("final insertion: \n<%s>", t_dummy_bind_inject)
            -- insertion_table:add_field({
            --     pos = "last",
            --     data = t_dummy_bind_inject,
            -- })
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
                    t_dummy_bind_inject,
                    1,
                    string.format("%s.binds = {", tostring(ts_module_identifier))
                )
                table.insert(t_dummy_bind_inject, "}")
                PS("final insertion: \n<%s>", t_dummy_bind_inject)
            end
        end

        -- TODO: run formatting on file
    end

    local function prepare_new_mapping()
        PS("Final RHS contents: <<%s>>", vim.inspect(user_input_rhs_contents))

        -- ! the key seq is already being parsed inside of v2, so maybe this
        -- could be passed to v2, instead of doing the parsing twice..
        new_lhs_parsed = _utils.parse_key_sequence(user_input_lhs)
        if not new_lhs_parsed then
            log.error("Couldnt parse the new LHS string")
            return
        end

        local is_leader_mappping = new_lhs_parsed[1]:match("<leader>")

        -- TODO: v2 needs to return the number of "parsed keys" that where removed,
        -- so that we know which key to accept new branch names from above.
        --
        _, _, insertion_data, target_buf = require(
            "doom.modules.core.nest.mapper.mappings_finder_v2"
        ).v2(module_path, user_input_lhs)

        print(
            "prepare_new_mapping: INSERTION TABLE:",
            insertion_data and insertion_data.ts_target_table
        )

        local accept_existing_branch_names = true

        if accept_existing_branch_names then
            PS(
                [[
        ----
        leftover parsed: %s
        trimmed_count: %s
        ----
        ]],
                vim.inspect(insertion_data.keys_parsed_leftover),
                insertion_data.trimmed_count
            )

            for i = 1, insertion_data.trimmed_count, 1 do
                table.remove(new_lhs_parsed, 1)
            end
        end

        if is_leader_mappping then
            -- If one accepts existing branch names, then we want add names
            -- for all new branch nodes, hence, why the `li` starts from 1,
            -- otherwise, when you build a new leader from scratch, then the
            -- leader name should always be the same.
            local li = insertion_data.trimmed_count > 0 and 1 or 2

            if not leader_branch_names then
                leader_branch_names = {}
            end

            local function get_branch_names_or_apply()
                if li < #new_lhs_parsed then
                    local helper_string = ""

                    for i, v in ipairs(new_lhs_parsed) do
                        local val = i == li and "(" .. v .. ")" or v
                        helper_string = string.format(
                            "%s %s",
                            helper_string,
                            i ~= #new_lhs_parsed and val or val .. " "
                        )
                    end

                    vim.ui.input(
                        { prompt = string.format("INPUT NAME for branch: {{%s}}", helper_string) },
                        function(input_branch_name)
                            li = li + 1

                            table.insert(leader_branch_names, input_branch_name)

                            get_branch_names_or_apply()
                        end
                    )
                else
                    build_new_mapping()
                end
            end
            get_branch_names_or_apply()
        else
            build_new_mapping()
        end
    end

    -- NOTE: The vim.ui... api requires nesting calls in a pipeline which is an
    -- akward pattern with large pipelines.

    vim.ui.input({ prompt = "INPUT NEW MAPPING NAME/DESCR: " }, function(input_name)
        user_input_name = input_name

        vim.ui.input({ prompt = "INPUT NEW LHS: " }, function(input_lhs)
            user_input_lhs = input_lhs

            vim.ui.select({ "STRING", "FUNCTION" }, {
                prompt = "WHAT TYPE OF RHS DO YOU WANT TO USE?",
            }, function(rhs_type_choice)
                if rhs_type_choice == "STRING" then
                    vim.ui.input({ prompt = "INPUT NEW RHS:" }, function(input_rhs)
                        user_input_rhs_contents = input_rhs
                        prepare_new_mapping()
                    end)
                elseif rhs_type_choice == "FUNCTION" then
                    rhs_is_func = true

                    --
                    -- Open a flow win for editing a single function out of
                    -- context.
                    -- Make this pattern reusable so that I can use it for
                    -- both creating AND editing existing mappings.
                    --

                    local rhs_buf_name = "RHS_BUF_NAME"
                    local rhs_buf_handle = vim.api.nvim_create_buf(true, true)
                    vim.api.nvim_buf_set_name(rhs_buf_handle, rhs_buf_name)
                    vim.bo[rhs_buf_handle].filetype = "lua"

                    local title = "Create RHS for LHS .... todo"

                    local client = vim.lsp.get_clients({ name = "lua_ls" })[1]
                    if client then
                        vim.lsp.buf_attach_client(rhs_buf_handle, client.id)
                        title = title .. " (LSP attached)"
                    else
                        -- TODO: Handle lua_ls not started.
                        title = title .. " (LSP unavailable)"
                    end

                    -- TODO: CENTER FLOAT WINDOW
                    --
                    -- local gheight = vim.api.nvim_list_uis()[1].height
                    -- local gwidth = vim.api.nvim_list_uis()[1].width
                    -- local width = 30
                    -- local height = 30
                    -- open_win_config = {
                    --     relative = "editor",
                    --     width = width,
                    --     height = height,
                    --     row = (gheight - height) * 0.5,
                    --     column = (gwidth - width) * 0.5,
                    -- }

                    local open_win_config = {
                        title = title,
                        title_pos = "right",
                        footer = "This is footer",
                        footer_pos = "center",
                        -- • relative: Sets the window layout to "floating", placed at
                        --   (row,col) coordinates relative to:
                        --   • "editor" The global editor grid
                        --   • "win" Window given by the `win` field, or current
                        --     window.
                        --   • "cursor" Cursor position in current window.
                        --   • "mouse" Mouse position
                        relative = "win",
                        row = 5,
                        col = 2,
                        width = 50,
                        height = 20,
                        border = "single",
                    }

                    -- WARN: Prevent the window from being moved around.

                    local rhs_win_handle =
                        vim.api.nvim_open_win(rhs_buf_handle, true, open_win_config)

                    -- close window / this is how we proceed to next step
                    vim.api.nvim_create_autocmd({ "BufDelete", "WinClosed" }, {
                        buffer = rhs_buf_handle,
                        callback = function(ev)
                            print(string.format("EVENT FIRED: %s", vim.inspect(ev)))
                            PS("diagnostics: <%s>", vim.inspect(vim.diagnostic.get(rhs_buf_handle)))

                            -- TODO: Handle diagnostics errors.

                            -- TODO: Capture the contents of the buffer

                            user_input_rhs_contents =
                                vim.api.nvim_buf_get_lines(rhs_buf_handle, 0, -1)

                            vim.api.nvim_buf_delete(rhs_buf_handle, {
                                force = true,
                            })

                            prepare_new_mapping()
                        end,
                    })

                    -- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
                    --   pattern = {"*.c", "*.h"},
                    --   callback = function(ev)
                    --     print(string.format('event fired: %s', vim.inspect(ev)))
                    --   end
                    -- })

                    -- TODO: capture contents of the buffer.
                    --  ~ parse with TS??
                end
            end)
        end)
    end)
end

M.select_filter_modes = function(prompt_bufnr) end

M.move_selected_binds_to_module = function(prompt_bufnr) end

-- TODO: toggle `:h index`, and external mappigs that comes from `:mapargs`
M.select_filter_mappings = function(prompt_bufnr) end

return M
