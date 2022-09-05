local utils = require("doom.utils")
local tsq = require("vim.treesitter.query")

-- TODO:
--
--    - split queries
--    - merge root module funcs into one
--    - sketch out component funcs.

local ts_query_template_mod_string = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor
              (field value: (string) @module_string (#eq? @module_string "\"%s\""))
        )
      )
  ) (#eq? @section_key "%s")
))
]]

local ts_query_template_mod_comment = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor (comment) @section_comment)
      )
  ) (#eq? @section_key "%s")
))
]]

local ts_query_template_s_and_c = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor
              (comment) @section_comment
              (field value: (string) @module_string (#eq? @module_string "\"%s\""))
        )
      )
  ) (#eq? @section_key "%s")
))
]]

local ts_query_template_section_table = [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor) @section_table; i want to get position of closing `}` and insert on line above.
      )
  ) (#eq? @section_key "%s")
))
]]

--
-- UTILS
--

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse()[1]
  return tree:root()
end

local get_query_capture = function(query, cname)
  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)

  local parsed = vim.treesitter.parse_query("lua", query)
  local root = get_root(buf)

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

  -- TODO:
  --
  --    return a table with
  return t, buf
end

local function insert_line(buf, line, value)
  vim.api.nvim_buf_set_lines(buf, line, line, true, { value })
end

-- local function replace_line(buf, line, value) end

local function set_text(buf, range, value)
  vim.api.nvim_buf_set_text(buf, range[1], range[2], range[3], range[4], { value })
end

local function get_string_name_range(node)
  return { node.range[1], node.range[2] + 1, node.range[3], node.range[4] - 1 }
end

local function get_comment_name_range(module_name, nodes, buf)
  for _, node in ipairs(nodes) do
    local match_str = '--%s-"' .. module_name .. '",'

    -- find position of module name in the comment
    if string.match(node.text, match_str) then
      local start_pos = string.find(node.text, module_name)
      local end_pos = start_pos + string.len(module_name)
      local indentation = node.range[2] - 1
      local name_real_start = indentation + start_pos
      local name_real_end = indentation + end_pos
      return { node.range[1], name_real_start, node.range[3], name_real_end }, true
    end
  end
  return nil, false
end

-- local get_text = function(node, bufnr)
-- end

--
-- MODULES UTIL
--

local M = {}

--
-- ROOT MODULES TS FUNCTIONS
--

M.root_modules_rename = function(section, module_name, new_name)
  local mod_str_node = get_query_capture(
    string.format(ts_query_template_mod_string, module_name, section),
    "module_string"
  )
  local comment_nodes, buf = get_query_capture(
    string.format(ts_query_template_mod_comment, section),
    "section_comment"
  )

  print("cn:", #comment_nodes)

  for _, v in pairs(comment_nodes) do
    print(v.text)
  end

  if mod_str_node[1] == nil and #comment_nodes == 0 then
    return false
  end
  local range
  if mod_str_node[1] then
    range = get_string_name_range(mod_str_node[1])
  elseif #comment_nodes > 0 then
    range = get_comment_name_range(module_name, comment_nodes, buf)
  end
  set_text(buf, range, new_name)
  return range
end

M.root_modules_new = function(section, module_name)
  local ts_query = string.format(ts_query_template_section_table, section)
  local section_table_node = get_query_capture(ts_query, "section_comment")
  local _, _, re, _ = section_table_node[1]:range()
  insert_line(buf, re, '    "' .. module_name .. '",')
end

M.root_modules_delete = function(section, module_name)
  local ts_query = string.format(ts_query_template_s_and_c, module_name, section)
  local mod_str_node = get_query_capture(ts_query, "module_string")
  local comment_nodes = get_query_capture(ts_query, "section_comment")
  if mod_str_node == nil and #comment_nodes == 0 then
    return false
  end
  local delete_line
  if mod_str_node then
    range = get_string_name_range(mod_str_node[1])
    delete_line = range[1]
  elseif #comment_nodes > 0 then
    range = get_comment_name_range(module_name, comment_nodes, buf)
    delete_line = range[1]
  end

  if delete_line then
    vim.api.nvim_buf_set_lines(buf, delete_line, delete_line, 0, {})
  end

  return delete_line
end

M.root_modules_toggle = function(section, module_name)
  local ts_query = string.format(ts_query_template_s_and_c, module_name, section)
  local mod_str_node = get_query_capture(ts_query, "module_string")
  local comment_nodes = get_query_capture(ts_query, "section_comment")
  if mod_str_node == nil and #comment_nodes == 0 then
    return false
  end
  local new_line, is_enabled
  if mod_str_node then
    range = get_string_name_range(mod_str_node[1])
    new_line = range[1]
    is_enabled = true
  elseif #comment_nodes > 0 then
    range, is_enabled = get_comment_name_range(module_name, comment_nodes, buf)
    new_line = range[1]
  end

  local new_str
  if is_enabled then
    new_str = string.format('    -- "%s",', module_name)
  else
    new_str = string.format('    "%s",', module_name)
  end

  if new_line then
    vim.api.nvim_buf_set_lines(buf, new_line, new_line, true, { new_str })
  end

  return new_line
end

--
-- GET FULL/EXTENDED TABLE OF ALL MODULES
--

-- FUTURE: filter levels instead -> since you might have a recursive module structure?
--    so that we don't need (origins/sections/mname) hardcoded -> used tree traversal instead.

-- can I shoe horn the usage of metatables into this file just so that I force myself to learn them?

M.extend = function(filter)
  local config_path = vim.fn.stdpath("config")

  local function glob_modules(cat)
    if cat ~= "doom" and cat ~= "user" then
      return
    end
    local glob = config_path .. "/lua/" .. cat .. "/modules/*/*/"
    return vim.split(vim.fn.glob(glob), "\n")
  end

  local function get_all_module_paths()
    local glob_doom_modules = glob_modules("doom")
    local glob_user_modules = glob_modules("user")
    local all = glob_doom_modules
    for _, p in ipairs(glob_user_modules) do
      table.insert(all, p)
    end
    return all
  end

  local function add_meta_data(paths)
    local prep_all_m = { doom = {}, user = {} }
    for _, p in ipairs(paths) do
      local m_origin, m_section, m_name = p:match("/([_%w]-)/modules/([_%w]-)/([_%w]-)/$") -- capture only dirname
      -- if user is empty for now..
      if m_origin == nil then
        break
      end
      if prep_all_m[m_origin][m_section] == nil then
        prep_all_m[m_origin][m_section] = {}
      end
      prep_all_m[m_origin][m_section][m_name] = {
        type = "doom_module_single",
        enabled = false,
        name = m_name,
        section = m_section,
        origin = m_origin,
        path = p,
      }
    end
    return prep_all_m
  end

  local function merge_with_enabled(prep_all_m)
    local enabled_modules = require("doom.core.modules").enabled_modules

    for section_name, section_modules in pairs(enabled_modules) do
      for _, module_name in pairs(section_modules) do
        local search_paths = {
          ("user.modules.%s.%s"):format(section_name, module_name),
          ("doom.modules.%s.%s"):format(section_name, module_name),
        }

        for _, path in ipairs(search_paths) do
          local origin = path:sub(1, 4)

          if prep_all_m[origin][section_name] ~= nil then
            if prep_all_m[origin][section_name][module_name] ~= nil then
              prep_all_m[origin][section_name][module_name].enabled = true
              for k, v in pairs(doom[section_name][module_name]) do
                prep_all_m[origin][section_name][module_name][k] = v
              end
              break
            end
          end
        end
      end
    end
    return prep_all_m
  end

  local function apply_filters(mods)
    -- AND type(filter) == "table"
    if filter and type(filter) == "table" then
      if filter.origins then
        for o, origin in pairs(mods) do
          if vim.tbl_contains(filter.origins, o) then
            table.remove(mods, o) -- filter origins
          else
            for s, section in pairs(origin) do
              if not vim.tbl_contains(filter.sections, s) then
                table.remove(mods[o], s) -- filter sections
              else
                for m, _ in pairs(section) do
                  if m.enabled ~= filter.enabled or not vim.tbl_contains(filter.names, m) then
                    table.remove(mods[o][s], m) -- filter modules by name
                  end
                end
              end
            end
          end
        end
      end
    end
    return mods
  end

  return apply_filters(merge_with_enabled(add_meta_data(get_all_module_paths())))
end

return M
