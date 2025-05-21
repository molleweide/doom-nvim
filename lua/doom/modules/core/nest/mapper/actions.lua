local utils = require("doom.utils")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local _utils = require("doom.modules.core.nest.mapper.utils")

local M = {}

M.jump_to_binding = function(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    local data = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(entry)
    local module_path = _utils.get_abs_path_from_module_origin(entry)

    if data.definition_stack then
        local stack = data.definition_stack
        local last = stack[#stack]
        local lhs_prefix_range = { last.prefix:range() }
        actions.close(prompt_bufnr)
        vim.cmd(string.format("edit %s", module_path))
        vim.api.nvim_win_set_cursor(0, { lhs_prefix_range[1] + 1, lhs_prefix_range[2] + 1 })
        vim.cmd("norm zz")
    else
        -- TODO: If has binds table, then jump to the binds table.
        actions.close(prompt_bufnr)
        vim.cmd(string.format("edit %s", module_path))
    end
end

M.edit_binding_name = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local finder = current_picker.finder
    local entry = action_state.get_selected_entry()
    local data = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(entry)

    vim.ui.input({ prompt = "Rename: ", default = entry.description }, function(input)
        vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt

        local stack = data.definition_stack
        local last = stack[#stack]

        PS("rename node: {{ %s }}", last.name:content())

        -- TODO: Ensure new name is unique and valid.

        last.name:content():replace(utils.escape_str(input))
    end)
end

M.edit_binding_rhs = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local finder = current_picker.finder
    local entry = action_state.get_selected_entry()
    local data = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(entry)

    -- TODO: if simple string -> then use vim.input...
    -- else, use popup buffer.

    vim.ui.input({ prompt = "Rename: ", default = entry.description }, function(input)
        vim.cmd([[ redraw ]]) -- redraw to clear out vim.ui.prompt to avoid hit-enter prompt
        local stack = data.definition_stack
        local last = stack[#stack]

        PS("rename node: {{ %s }}", last.name:content())
    end)
end

-- TODO: ADD NEW [normal] BIND W/ DUMMY RHS ACTION
-- ~~ ( ) First, just add the binding if leaf does not exist, regardless of branch names.
-- ~~ ( ) If no selection, add to [config.lua]
-- ~~ ( ) Else, add to selected module.
M.edit_binding_add_new = function(prompt_bufnr) end

M.select_filter_modes = function(prompt_bufnr) end

M.move_selected_binds_to_module = function(prompt_bufnr) end

-- TODO: toggle `:h index`, and external mappigs that comes from `:mapargs`
M.select_filter_mappings = function(prompt_bufnr) end

return M
