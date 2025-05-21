local actions = require "telescope.actions"
local action_set = require "telescope.actions.set"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local Path = require "plenary.path"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local p_window = require "telescope.pickers.window"
local state = require "telescope.state"
local utils = require "telescope.utils"

local conf = require("telescope.config").values

internal.commands = function(opts)
  pickers
    .new(opts, {
      prompt_title = "Commands",
      finder = finders.new_table {
        results = (function()
          local command_iter = vim.api.nvim_get_commands {}
          local commands = {}

          for _, cmd in pairs(command_iter) do
            table.insert(commands, cmd)
          end

          local need_buf_command = vim.F.if_nil(opts.show_buf_command, true)

          if need_buf_command then
            local buf_command_iter = vim.api.nvim_buf_get_commands(0, {})
            buf_command_iter[true] = nil -- remove the redundant entry
            for _, cmd in pairs(buf_command_iter) do
              table.insert(commands, cmd)
            end
          end
          return commands
        end)(),

        entry_maker = opts.entry_maker or make_entry.gen_from_commands(opts),
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if selection == nil then
            utils.__warn_no_selection "builtin.commands"
            return
          end

          actions.close(prompt_bufnr)
          local val = selection.value
          local cmd = string.format([[:%s ]], val.name)

          if val.nargs == "0" then
            local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
            cmd = cmd .. cr
          end
          vim.cmd [[stopinsert]]
          vim.api.nvim_feedkeys(cmd, "nt", false)
        end)

        return true
      end,
    })
    :find()
end

