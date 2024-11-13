local utils = require("doom.utils")

-- TODO: rename to: command_monitor

local M = {}

local mod_name = "TjTest"

-- make open in a split buffer

-- NOTE: This allows you to setup an autocmd that looks at a specific
-- pattern. eg *.lua all lua files. and on save it will then run command
-- X and put whatever std io to the buffer we target.
--
-- TODO: put create new win / buf
--
-- TEST: How can I stop the process after it has been started?
-- >>> I need a picker to list all existing autocmds

local attach_to_buffer = function(buf_out, pattern, command, name, descr)
  print("chosen buf: ", buf_out)

  local append_data = function(_, data)
    if data then
      vim.api.nvim_buf_set_lines(buf_out, -1, -1, false, data)
    end
  end

    -- FIX: use vim.system() instead

  -- FIX: doom autocmds so that I can add the name and description to them,
  -- so that it becomes easier for myself to manage them and disable autocmds.
  --
  utils.make_autocmd("BufWritePost", pattern, function()
    vim.api.nvim_buf_set_lines(buf_out, 0, -1, false, { "TESTING" })
    vim.fn.jobstart(command, {
      stdout_buffered = true,
      on_stdout = append_data,
      on_stderr = append_data,
    })
  end, mod_name)
end

M.cmds = {
  {
    mod_name,
    function()
      local name = vim.fn.input("Job name: ")
      local description = vim.fn.input("Job description: ")
      local bufnr = vim.fn.input("Bufnr: ")
      local pattern = vim.fn.input("Pattern: ")
      local command = vim.split(vim.fn.input("Command: "), " ")
      attach_to_buffer(tonumber(bufnr), pattern, command, name, description)
    end,
  },
}

return M
