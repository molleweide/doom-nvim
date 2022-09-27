local dui_utils = {}

dui_utils.get_buf_handle = function(path)
  local buf
  if path ~= nil then
    buf = vim.uri_to_bufnr(vim.uri_from_fname(path))
  else
    buf = vim.api.nvim_get_current_buf()
  end
  return buf
end

dui_utils.tbl_merge = function(t1, t2)
  local ret = vim.deepcopy(t1)
  for _, p in ipairs(t2) do
    table.insert(ret, p)
  end
  return ret
end

return dui_utils
