
local function surround_visual_selection_with_jsx_comment()
  local utils = require("doom.utils")

  local vis_sel = utils.get_visual_selection()

  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")

  -- NOTE: [bufnum, lnum, col, off]

  print("start", vim.inspect(s_start))
  print("end", vim.inspect(s_end))

  print(s_start[1])

  if s_start[3] > 1000 then
    return
  end

  local buf = s_start[1]
  local  start_row = s_start[2] - 1
  local  end_row = s_end[2] -1


  vim.api.nvim_buf_set_text(
    buf,
    end_row,
    s_end[3],
    end_row,
    s_end[3],
    { "*/}" }
  )
  vim.api.nvim_buf_set_text(
    buf,
    start_row,
    s_start[3] - 1,
    start_row,
    s_start[3] - 1,
    { "{/*" }
  )

  -- NOTE: I need to escape back to normal mode.
  local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(keys, "v", true)



  -- insert start
end
