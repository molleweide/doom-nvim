local previewers = require("telescope.previewers")
local utils = require("telescope.utils")
local defaulter = utils.make_default_callable
-- local mapper = require("nvim-mapper")
local _utils = require("doom.modules.core.nest.mapper.utils")

-- TODO: show the origin module path in the previewer.
-- get info about user/core

local M = {}

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

            -- test
            vim.api.nvim_buf_set_lines(
                self.state.bufnr,
                -1,
                -1,
                false,
                { "Path -> ".._utils.get_short_path_from_module_origin(entry) }
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
        end,
    })
end, {})

return M
