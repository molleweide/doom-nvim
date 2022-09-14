local log = require("doom.utils.logging")
local utils = require("doom.utils")
local tsq = require("vim.treesitter.query")

local ts = {}

ts.get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse()[1]
  return tree:root()
end

-- TODO: allow chained scopes
ts.get_captures = function(path, q1, c1, q2, c2)
  local path = path or utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(path)
  local root = ts.get_root(buf)
  local t1 = {}
  local t2 = {}

  -- NOTE: this prints long after I am expecting it to print??!
  -- log.info(q1, "\n", q2)

  if q2 and c2 then
    local parsed1 = vim.treesitter.parse_query("lua", q1)
    for id, node, _ in parsed1:iter_captures(root, buf, 0, -1) do
      local name = parsed1.captures[id]
      if name == c1 then
        table.insert(t1, {
          node = node,
          text = tsq.get_node_text(node, buf),
          range = { node:range() },
        })
      end
    end
  else
    q2 = q1
    c2 = c1
  end

  local parsed2 = vim.treesitter.parse_query("lua", q2)
  for id, node, _ in parsed2:iter_captures(root, buf, 0, -1) do
    local name = parsed2.captures[id]
    if name == c2 then
      table.insert(t2, {
        node = node,
        text = tsq.get_node_text(node, buf),
        range = { node:range() },
      })
    end
  end

  return t2, buf
end

return ts
