-- telescope modules
local log = require("doom.utils.logging")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- telescope-mapper modules
local _finders = require("doom.modules.core.nest.mapper.finders")
local _previewers = require("doom.modules.core.nest.mapper.previewers")
local _utils = require("doom.modules.core.nest.mapper.utils")

local M = {}

-- if vim.g.mapper_action_on_enter == "definition" and vim.g.mapper_modules_dir then
M.mapper = function(opts)
    local function prepare_args(keybind)
        return {
            module_path = _utils.get_abs_path_from_module_origin(keybind),
            keybind = keybind,
            keys_parsed = _utils.parse_key_sequence(keybind.keys),
        }
    end

    -- open file in split
    local function open(args)
        vim.cmd(string.format("e %s", args.module_path))
        vim.cmd("stopinsert")
    end

    opts = vim.tbl_extend("force", opts or {}, {
        attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            -- <CR> jump to LHS
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                local data = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(entry)
                local module_path = _utils.get_abs_path_from_module_origin(entry)

                if data.definition_stack then
                    local stack = data.definition_stack
                    local last = stack[#stack].prefix
                    -- local parent_table_last = last(last:parent():parent()) -- get the leaf table_constructor.
                    local lhs_prefix_range = { last:range() }
                    actions.close(prompt_bufnr)
                    vim.cmd(string.format("edit %s", module_path))
                    vim.api.nvim_win_set_cursor(0, { lhs_prefix_range[1] + 1, lhs_prefix_range[2]+1 })
                    vim.cmd("norm zz")
                else
                    -- TODO: If has binds table, then jump to the binds table.
                    actions.close(prompt_bufnr)
                    vim.cmd(string.format("edit %s", module_path))
                end
            end)

            return true
        end,
    })

    pickers
        .new(opts or {}, {
            prompt_title = "Select a mapping",
            results_title = "Mappings",
            finder = _finders.mapper_finder(_utils.get_mappers()),
            sorter = conf.generic_sorter(opts),
            previewer = _previewers.previewer.new(opts),
        })
        :find()
end

return M
