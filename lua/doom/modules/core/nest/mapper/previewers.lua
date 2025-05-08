local previewers = require("telescope.previewers")
local utils = require("telescope.utils")
local defaulter = utils.make_default_callable
-- local mapper = require("nvim-mapper")
local _utils = require("doom.modules.core.nest.mapper.utils")

-- TODO: show the origin module path in the previewer.
-- get info about user/core

local M = {}

-- ENTRY: {
--   buffer_only = false,
--   category = "+file",
--   cmd = "<cmd>SudaWrite<CR>",
--   description = "Write with sudo",
--   description_display = "Write with sudo",
--   display = <function 1>,
--   id = "write_with_sudo_n",
--   index = 2,
--   keys = "<leader>fW",
--   lines = { "Id:           write_with_sudo_n", "Category:     +file", "Mode:         normal", "Keys:         <leader>fW", "Command:      <cmd>SudaWrite<CR>", "Buffer only:  false", "Options:      {noremap = true, silent = true}", "Definition:   :", "Origin:       features.suda", "", "Write with sudo" },
--   mode = "n",
--   module_origin = "features.suda",
--   options = {
--     noremap = true,
--     silent = true
--   },
--   ordinal = "Write with sudowrite_with_sudo_n<leader>fW+file",
--   unique_identifier = "write_with_sudo_n",
--   value = "Write with sudo"
-- }

M.previewer = defaulter(function(_)
    return previewers.new_buffer_previewer({
        title = "Mapping details",
        define_preview = function(self, entry, _)
            -- Write the entry lines
            local lines = entry.lines

            print("LINES:", vim.inspect(entry))
            -- for _, l in ipairs(lines) do
            -- print(l)
            -- end

            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

            -- test: append line
            vim.api.nvim_buf_set_lines(
                self.state.bufnr,
                -1,
                -1,
                false,
                { "Path -> " .. _utils.get_short_path_from_module_origin(entry) }
            )

            -- Set wrap for the preview window
            vim.api.nvim_win_set_option(self.state.winid, "wrap", true)

            -- Color
            local syntax_matches = {
                nvim_mapper_id = "^Id",
                nvim_mapper_cat = "^Category",
                nvim_mapper_mode = "^Mode",
                nvim_mapper_keys = "^Keys",
                nvim_mapper_cmd = "^Command",
                nvim_mapper_buf_only = "^Buffer only",
                nvim_mapper_description = "^Description",
                nvim_mapper_opts = "^Options",
                nvim_mapper_definition = "^Definition",
            }

            -- Syntax colors
            for key, value in pairs(syntax_matches) do
                vim.api.nvim_buf_call(self.state.bufnr, function()
                    vim.cmd(":syntax match " .. key .. ' "' .. value .. '"')
                end)

                vim.api.nvim_buf_call(self.state.bufnr, function()
                    vim.cmd(":hi link " .. key .. " Operator")
                end)

                if
                    key == "nvim_mapper_keys"
                    or key == "nvim_mapper_cmd"
                    or key == "nvim_mapper_opts"
                    or key == "nvim_mapper_id"
                    or key == "nvim_mapper_definition"
                then
                    vim.api.nvim_buf_call(self.state.bufnr, function()
                        -- "\(^Definition: \+\)\@<=.*"
                        vim.cmd(":syntax match MapperCode '\\(" .. value .. ": \\+\\)\\@<=.*'")
                    end)
                end
                vim.api.nvim_buf_call(self.state.bufnr, function()
                    vim.cmd(":hi link MapperCode Comment")
                end)
            end

            -- require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(args)
            local captures = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(entry)

            for i, v in ipairs(captures) do
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    -1,
                    -1,
                    false,
                    vim.split(tostring(v), "\n")
                )
            end
        end,
    })
end, {})

return M
