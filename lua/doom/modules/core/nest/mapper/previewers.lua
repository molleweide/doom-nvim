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

local function ts_contents_2_table(ts_node)
    return vim.split(tostring(ts_node), "\n")
end

local Helper = {}
Helper.__index = Helper

function Helper.new(bufnr)
    local o = { bufnr = bufnr }
    return setmetatable(o, Helper)
end

function Helper:append(data)
    vim.api.nvim_buf_set_lines(
        self.bufnr,
        -1,
        -1,
        false,
        type(data) == "string" and { data } or data
    )
end

M.previewer = defaulter(function(_)
    return previewers.new_buffer_previewer({
        title = "Mapping details",
        define_preview = function(self, entry, _)
            local helper = Helper.new(self.state.bufnr)
            local lines = entry.lines
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

            P(entry)


            local module_path = _utils.get_abs_path_from_module_origin(entry.module_origin)
            local _, bind_stack = require("doom.modules.core.nest.mapper.mappings_finder_v2").v2(
                module_path,
                entry.keys
            )

            -- local bind_stack = data.definition_stack

            helper:append("Path -> " .. _utils.get_short_path_from_module_origin(entry.module_origin))

            if bind_stack then
                local leaf = bind_stack[#bind_stack]

                print("previews leaf = ", leaf)

                -- show branch
                helper:append("---------------------------------")
                helper:append("BRANCH / NAME:")
                local names = {}
                for k, v in pairs(bind_stack) do
                    if v.name then
                        table.insert(names, string.format("[%s]", tostring(v.name:content())))
                    end
                end
                helper:append({ "", table.concat(names, " -> "), "" })

                -- show rhs
                helper:append({ "---------------------------------", "RIGHT HAND SIDE (RHS):", "" })
                local rhs = leaf.rhs
                if rhs:type() == "string" then
                    helper:append(ts_contents_2_table(rhs:content()))
                elseif rhs:type() == "function_definition" then
                    helper:append(ts_contents_2_table(rhs))
                elseif rhs:type() == "identifier" then
                end
                helper:append("")

                -- show explicit options
                if leaf.options then
                    helper:append({
                        "---------------------------------",
                        "EXPLICITLY DECLARED OPTIONS:",
                        "",
                    })
                    helper:append(ts_contents_2_table(leaf.options))
                end
            end

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

            helper:append("---------------------------------")

            -- NOTE: failing modules:
            --      ~ refactoring (uses table.insert)

            if bind_stack then
                local first = bind_stack[1].prefix
                local last = bind_stack[#bind_stack].prefix
                local parent_table = first(first:parent():parent())
                local parent_table_last = last(last:parent():parent())

                helper:append("---------------------------------")
                helper:append("definition leaf:")

                helper:append(vim.split(tostring(parent_table_last), "\n"))

                helper:append("---------------------------------")
                helper:append("parent binds table:")

                helper:append(vim.split(tostring(parent_table), "\n"))
            else
                print("data:", data.definition_stack)

                helper:append("Could not find a mappings_definition")
            end
        end,
    })
end, {})

return M
