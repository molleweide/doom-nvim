-- telescope modules
local log = require("doom.utils.logging")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local system = require("doom.core.system")
local utils = require("doom.utils")
local fs = require("doom.utils.fs")
local ts = vim.treesitter

local b = require("doom.modules.features.dui.buf")

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

            map({ "i", "n" }, "<C-s>", function()
                _G.__monitor_doom_debug_binds = prepare_args(action_state.get_selected_entry())
                actions.close(prompt_bufnr)
            end, { desc = "Set the global __monitor_<name> var." })

            map("i", "<C-q>", function()
                local args = prepare_args(action_state.get_selected_entry())
                if not args.module_path then
                    log.info("nest telescope -> did not return a proper module_path")
                    return
                end
                actions.close(prompt_bufnr)

                open(args)

                -- Bind the output to the buffer monitor module so that we can
                -- use the output as the value for the output to the buff monitor.
                _G.__monitor_doom_debug_binds = args

                require("doom.modules.core.nest.mapper.mappings_finder_v1").get_match_for_keybind(
                    args
                )
            end, { desc = "Go to mapping [V1]" })

            -- NOTE: V2
            actions.select_default:replace(function()
                local args = prepare_args(action_state.get_selected_entry())
                if not args.module_path then
                    log.info("nest telescope -> did not return a proper module_path")
                    return
                end
                require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(args)
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
