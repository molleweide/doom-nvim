local utils = require("doom.utils")
local tsq = require("vim.treesitter.query")

local ts = {}

ts.get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse()[1]
  return tree:root()
end

-- get_captures
--
--        path/buf
--
--        queryN, captureN,
--        queryN, captureN,
--        queryN, captureN,
--
ts.get_captures = function(query, cname, path, scope)

  local args = ...




  -- loop args,
  --
  --    process queries.



  -- if not path then
  path = path or utils.find_config("modules.lua")
  -- end
  local buf = utils.get_buf_handle(path)

  local parsed = vim.treesitter.parse_query("lua", query)
  local root = ts.get_root(buf)

  local t = {}

  for id, node, _ in parsed:iter_captures(root, buf, 0, -1) do
    local name = parsed.captures[id]
    if name == cname then
      table.insert(t, {
        node = node,
        text = tsq.get_node_text(node, buf),
        range = { node:range() },
      })
    end
  end

  return t, buf
end

return ts

-------------------------------------------------------------------------------
-- DUI / TS_TRAVERSE
-------------------------------------------------------------------------------

-- local tsq = require("vim.treesitter.query")
-- local parsers = require "nvim-treesitter.parsers"
--
-- local tst = {}
--
-- -- THIS IS A REWRITE OF `SERVICES/KEYMAPS` WITH TREESITTERE, IE. IT FOLLOWS THE EXACT SAME
-- -- PATTERN BUT NODES ARE ITERATED WITH TS INSTEAD OF REGULAR LUA TABLE.
--
-- tst.parse_nest_tables_meta_data = function(buf, node, accumulated,level)
--   if accumulated == nil then
--     accumulated = {
--       level = 0,
--     }
--   else
--     accumulated.level = level + 1
--   end
--   accumulated["container"] = node
--   -- print(level, "--------------------------------------------")
--   if node:type() == nil or node:type() ~= "table_constructor" then
--     return false
--   end
--   local cnt = 1 -- child counter
--   local special_cnt = 0
--   local second_table
--   local second_table_idx
--   local second_table_cnt = 0
--   local rhs
--   local name_found
--   local mode_found
--   local opts_found
--   local desc_found
--   for n in node:iter_children() do
--     if n:named() then
--     local the_node = n:named_child(0) -- table constructor
--     local the_type = the_node:type(0)
--     if cnt == 1 then
--       if the_type == "table_constructor" then
--         -- accumulated["children"] = {}
--         local child_table = {
-- 		type = "binds_table"
-- 	}
--         for child in node:iter_children() do
--           if child:named() then
--             if child:type() == "field" then
--               table.insert(child_table,
--                 tst.parse_nest_tables_meta_data(buf, child:named_child(0), {}, accumulated.level)
--                 )
--             end
--           end
--         end
--         table.insert(accumulated, child_table)
--         return accumulated
--       else
--         accumulated["prefix"] = the_node
-- 	      accumulated["type"] = "binds_leaf"
--         local nt = tsq.get_node_text(the_node, buf)
-- 	      accumulated["prefix_text"] = nt
--         special_cnt = special_cnt + 1
--       end
--     end
--     if cnt ~= 1 then
--       if the_type == "table_constructor" then
--         second_table = the_node
--         second_table_idx = special_cnt
--         second_table_cnt = second_table_cnt + 1
--       end
--     end
--     if cnt == 2 and (the_type == "string" or the_type == "function_definition" or the_type == "dot_index_expression")then
--         rhs = the_node
--     end
--     local c2 = n:named_child(0)
--     if c2:type() == "identifier" then
--       local nt = tsq.get_node_text(c2, buf)
--       if nt == "name" then
--         accumulated["name"] = c2
--         name_found = true
--         special_cnt = special_cnt + 1
--       elseif nt == "mode" then
--         accumulated["mode"] = c2
--         mode_found = true
--         special_cnt = special_cnt + 1
--       elseif nt == "description" then
--         accumulated["description"] = c2
--         desc_found = true
--         special_cnt = special_cnt + 1
--       elseif nt == "options" then
--         accumulated["options"] = c2
--         opts_found = true
--         special_cnt = special_cnt + 1
--       else
--         rhs = the_node
--       end
--     end
--     cnt = cnt + 1
--     end
--   end
--   if accumulated.name == nil and special_cnt >= 3 then
--     accumulated["name"] = node:named_child(2)
--   end
--   if accumulated.description == nil and special_cnt >= 4 then
--     accumulated["description"] = node:named_child(3)
--   end
--   if accumulated.rhs == nil and second_table then
--     rhs = second_table
--     accumulated["type"] = "binds_branch"
--   end
--   accumulated["rhs"] = rhs
--   if accumulated.rhs:type() == "table_constructor" then
--     accumulated["rhs"] = tst.parse_nest_tables_meta_data(buf, accumulated.rhs, {}, level)
--   end
--   return accumulated
-- end
--
-- return tst

-------------------------------------------------------------------------------
-- DUI / TS
-------------------------------------------------------------------------------

-- local utils = require("doom.utils")
-- local fs = require("doom.utils.fs")
-- local system = require("doom.core.system")
--
-- -- TREESITTER
-- local tsq = require("vim.treesitter.query")
-- local parsers = require "nvim-treesitter.parsers"
--
-- local M = {}
--
--
-- local ROOT_MODULES = utils.find_config("modules.lua")
--
-- M.ntext = function(n,b) return tsq.get_node_text(n, b) end
--
-- -- system.sep!!! -> util?
-- M.get_query_file = function(lang, query_name)
--   return fs.read_file(string.format("%s/queries/%s/%s.scm", system.doom_root, lang, query_name))
-- end
--
-- M.ts_get_doom_captures = function(buf, doom_capture_name)
--   local t_matched_captures = {}
--   local query_str = M.get_query_file("lua", "doom_conf_ui")
--   local language_tree = vim.treesitter.get_parser(buf, "lua")
--   local syntax_tree = language_tree:parse()
--   local root = syntax_tree[1]:root()
--   local qp = vim.treesitter.parse_query("lua", query_str)
--
--   for id, node, _ in qp:iter_captures(root, buf, root:start(), root:end_()) do
--     local name = qp.captures[id]
-- 	  if name == doom_capture_name then
--         table.insert(t_matched_captures, node)
-- 	  end
--    end
--    return t_matched_captures
-- end
-- -- I BELIEVE THAT THIS FUNCTION ALSO EXPECTS THE (TABLE_CONSTRUCTOR) NODE
-- -- AS INPUT.
-- M.transform_root_mod_file = function(m, cb)
--
--   local buf = utils.get_buf_handle(ROOT_MODULES)
--
--   local query_str = doom_ui.get_query_file("lua", "doom_root_modules")
--   local language_tree = vim.treesitter.get_parser(buf, "lua")
--   local syntax_tree = language_tree:parse()
--   local root = syntax_tree[1]:root()
--   local qp = vim.treesitter.parse_query("lua", query_str)
--
--   local sm_ll = 0 -- section module last line
--
--   if qp ~= nil then
--     for id, node, metadata in qp:iter_captures(root, buf, root:start(), root:end_()) do
--       local cname = qp.captures[id] -- name of the capture in the query
--       local node_text = ntext(node, buf)
--       -- local p = node:parent()
--       local ps = (node:parent()):prev_sibling()
--       if ps ~= nil then
--         local pss = ps:prev_sibling()
--         if pss ~= nil then
--           local section_text = ntext(pss, buf)
--           if m.section == section_text then
--             sm_ll, _, _, _ = node:range()
--             if cb ~= nil then
--               cb(buf, node, cname, node_text)
--             end
--           end
--         end
--       end
--     end
--   end
--   -- vim.api.nvim_win_set_buf(0, buf)
--   return buf, sm_ll + 1
-- end
--
-- M.gen_query_for_selection = function()
--   -- helper to allow for using the already existing doom table instead of having to
--   -- parse eg. the nest tree before initiating pickers.
--   -- on selection -> generate a query that targets the selection.
--   -- --> apply code actions.
-- end
--
-- return M

-------------------------------------------------------------------------------
-- USER UTILS TS
-------------------------------------------------------------------------------

--
-- local utils = require("doom.utils")
-- local fs = require("doom.utils.fs")
-- local system = require("doom.core.system")
-- local user_paths = require("user.utils.path")
-- local tsq = require("vim.treesitter.query")
-- local api = vim.api
-- local cmd = api.nvim_command
--
-- local M = {}
--
-- -- create helper functions that can be nice and useful.
-- -- ALSO ANNOTATE IF THE FUNCTION ALREADY EXISTS IN A PLUGIN
-- -- such as nvim-treesitter.ts_utils.
-- --
--
-- -- ts.remove_unused_locals(bufnr)
--
-- -- ts.get_parsed_query()
-- -- ts.return_captures_from_parsed_query(qp, { list of capture names you want to return })
-- -- ts.prepend_line_of_node_with(node,"-- ",offset)
-- -- ts.append_line_of_node_with(node,"-- ",offset)
-- -- ts.insert_text_before_node(node,"-- ", offset)
-- -- ts.insert_text_after_node(node,"-- ", offset)
-- -- ts.surround_node_with_text(node,"-- ", offset)
-- --
--
-- M.get_query_file = function(lang, query_name)
--   return fs.read_file(string.format("%s/queries/%s/%s.scm", system.doom_root, lang, query_name))
-- end
--
-- -- get_query_on_buf
-- M.get_query = function(query_str, bufnr)
--   if bufnr == nil then
--     bufnr = api.nvim_get_current_buf()
--   end
--   local language_tree = vim.treesitter.get_parser(bufnr)
--   local syntax_tree = language_tree:parse()
--   local root = syntax_tree[1]:root()
--   local q = vim.treesitter.parse_query("lua", query_str)
--   return bufnr, root, q
-- end
--
-- M.get_query_on_file = function(lang, query_name, path_target)
--   local query_str = M.get_query_file(lang, query_name)
--   local source_str = fs.read_file(path_target)
--   local language_tree_parser_str = vim.treesitter.get_string_parser(source_str, lang)
--   local syntax_tree = language_tree_parser_str:parse()
--   local root = syntax_tree[1]:root()
--   local q = vim.treesitter.parse_query(lang, query_str)
--   return source_str, root, q
-- end
--
-- M.run_query_on_buf = function(lang, query_name, buf)
--   print("buf: ", buf)
--   local query_str = M.get_query_file(lang, query_name)
--   local language_tree = vim.treesitter.get_parser(buf, lang)
--   local syntax_tree = language_tree:parse()
--   local root = syntax_tree[1]:root()
--   local q = vim.treesitter.parse_query(lang, query_str)
--   return buf, root, q
-- end
--
-- -- M.get
--
-- M.log_captures = function(root, bufnr, q)
--   if q ~= nil then
--     local id_done = {}
--     local iterated_captures = {}
--     for id, node, metadata in q:iter_captures(root, bufnr, root:start(), root:end_()) do
--       local name = q.captures[id]
--       local nt = tsq.get_node_text(node, bufnr)
--       -- if not vim.tbl_contains(id_done, id) then
--       --   table.insert(id_done, id)
--       -- table.insert(iterated_captures, { id = id, node = node, metadata = metadata })
--       -- end
--       print(string.format([[ %s: (%s) -> `%s` ]], id, name, nt))
--     end
--
--     print("::: log captures :::::::::::::::::::::::::::::::::::::::::::::::")
--
--     -- for _, c in ipairs(iterated_captures) do
--     --   local name = q.captures[c.id]
--     --   local nt = tsq.get_node_text(c.node, bufnr)
--     --   local sr, sc, er, ec = c.node:range()
--     --   print(
--     --     string.format([[ %s: (%s) -> `%s`  [%s %s, %s %s] ]], c.id, name, nt, sr + 1, sc, er + 1, ec)
--     --   )
--     -- end
--   end
-- end
--
-- M.get_unique_captures = function() end
--
-- M.get_captures = function(root, bufnr, q, capture_name)
--   local capture_name_matches = {}
--   if q ~= nil then
--     for id, node, metadata in q:iter_captures(root, bufnr, root:start(), root:end_()) do
--       local name = q.captures[id] -- name of the capture in the query
--
--       -- refactor into function get_capture from query
--       if name == capture_name then
--         table.insert(capture_name_matches, node)
--       end
--     end
--   end
--   return capture_name_matches
-- end
--
-- M.get_captures_from_multiple_files_with_STRING_PARSER = function()
--   local mult_file_captures = {
--     filepath = "",
--     node = nil,
--   }
--   local umps = user_paths.get_user_mod_paths()
--   -- for each path
--   -- ts parse for package_string captures
--   -- store in table
--
--   return mult_file_captures
-- end
--
-- M.ts_single_node_prepend_text = function(node, bufnr, prepend_text)
--   local type = node:type() -- type of the captured node
--   local nt = tsq.get_node_text(node, bufnr)
--   local sr, sc, er, ec = node:range()
--   print(string.format("type: %s, text: %s, [%s %s, %s %s]", type, nt, sr + 1, sc, er + 1, ec))
--   api.nvim_buf_set_text(bufnr, sr, sc, sr, sc, { prepend_text })
--   return bufnr
-- end
--
-- M.ts_single_node_append_text = function(node, bufnr, prepend_text)
--   local type = node:type() -- type of the captured node
--   local nt = tsq.get_node_text(node, bufnr)
--   local sr, sc, er, ec = node:range()
--   print(string.format("type: %s, text: %s, [%s %s, %s %s]", type, nt, sr + 1, sc, er + 1, ec))
--   api.nvim_buf_set_text(bufnr, er, ec, er, ec, { prepend_text })
-- end
--
-- M.single_node_inner_text_transform = function(node, source, mode)
--
--   -- 1 replace from beginning "L"
--   -- 2 replace from end "R"
--   -- 3 replace from both both "B"
--   -- 4 full swap inner text with repl "F"
-- end
--
-- -- @param table
-- -- loop and apply
-- M.ts_nodes_prepend_text = function(nodes, bufnr, prepend_text)
--   for i, v in ipairs(nodes) do
--     M.ts_single_node_prepend_text(v, bufnr, prepend_text)
--   end
-- end
--
-- M.ts_nodes_append_text = function(nodes, bufnr, prepend_text)
--   for i, v in ipairs(nodes) do
--     M.ts_single_node_append_text(v, bufnr, prepend_text)
--   end
-- end
-- -- M.ts_node_append_text = function(node) end
-- -- M.ts_node_surround_text = function(node) end
--
-- return M
