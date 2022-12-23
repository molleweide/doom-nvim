local utils = require("doom.utils")

local M = {}

local mod_name = "TjTest"

-- make open in a split buffer

local attach_to_buffer = function(buf_out, pattern, command)
  print("chosen buf: ", buf_out)

  local append_data = function(_, data)
    if data then
      vim.api.nvim_buf_set_lines(buf_out, -1, -1, false, data)
    end
  end

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
      local bufnr = vim.fn.input("Bufnr: ")
      local pattern = vim.fn.input("Pattern: ")
      local command = vim.split(vim.fn.input("Command: "), " ")
      attach_to_buffer(tonumber(bufnr), pattern, command)
    end,
  },
}

return M
