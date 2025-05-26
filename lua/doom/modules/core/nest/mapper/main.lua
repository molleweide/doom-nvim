-- telescope modules
local log = require("doom.utils.logging")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

-- telescope-mapper modules
local _finders = require("doom.modules.core.nest.mapper.finders")
local _previewers = require("doom.modules.core.nest.mapper.previewers")
local _utils = require("doom.modules.core.nest.mapper.utils")

local bindings_actions = require("doom.modules.core.nest.mapper.actions")

local M = {}

M.mapper = function(opts)
    opts = vim.tbl_extend("force", opts or {}, {
        attach_mappings = function(_, map)
            actions.select_default:replace(bindings_actions.jump_to_binding)

            map("i", "<C-r>", bindings_actions.edit_binding_name, { desc = "UPDATE NAME" })
            map("i", "<C-e>", bindings_actions.edit_binding_rhs, { desc = "UPDATE RHS" })
            map("i", "<C-a>", bindings_actions.add_new_dummy_bind, { desc = "ADD NEW DUMMY BIND" })


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
