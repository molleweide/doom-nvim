local utils = require("doom.utils")
local tsq = require("vim.treesitter.query")

-- TODO:
--
--    - refactor string/comment analysis into utils below
--
--    - move all queries into a queries table.
--
--    - refactor as much as possible into
--      ts utils?
--
--      iterate captures for query on path/buf

--
-- UTILS
--

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse()[1]
  return tree:root()
end

local iter_captures_on_config_modules = function(buf, query, iter_cb)

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


-- Description:
--
--    Analyzes `modules.lua` file to find the ranges where a module is located
--    even if the module is disabled (commented out).
--
--
-- Return:
--
--    return ranges for the module, or false -> not found
M.root_modules_rename = function(section, module_name)
  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)

  -- NOTE: I split the query for `string` and `comments` in two since using a single query gave me confusing results, even though I think this should be possible with a single query?!

  -- TODO: split this into two queries?
  local ts_query_module_str = string.format([[]], module_name, section)

  local ts_query_comment = [[]]

  -- this query works perfectly with `TSPlayground` but it does not return captures as I expect when
  -- used below.
  local ts_query = string.format(
    [[
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
]],
    module_name,
    section
  )

  local parsed = vim.treesitter.parse_query("lua", ts_query)
  local root = get_root(buf)
  local mod_str_node
  local comment_nodes = {}
  local mname_range

  for id, node, _ in parsed:iter_captures(root, buf, 0, -1) do
    local name = parsed.captures[id]
    if name == "module_string" then
      mod_str_node = node
    elseif name == "section_comment" then
      table.insert(comment_nodes, node)
    end
  end

  if mod_str_node == nil and #comment_nodes == 0 then
    return false
  end

  if mod_str_node then
    local t = tsq.get_node_text(mod_str_node, buf)
    print("found string: ", t)
    local rs, cs, re, ce = mod_str_node:range()
    mname_range = { rs, cs + 1, re, ce - 1 }
  elseif #comment_nodes > 0 then
    for _, node in ipairs(comment_nodes) do
      local t = tsq.get_node_text(node, buf)
      local match_str = '--%s-"' .. module_name .. '",'

      -- find position of module name in the comment
      if string.match(t, match_str) then
        local start_pos = string.find(t, module_name)
        local end_pos = start_pos + string.len(module_name)
        local rs, cs, re, ce = node:range()
        local indentation = cs - 1
        local name_real_start = indentation + start_pos
        local name_real_end = indentation + end_pos
        mname_range = { rs, name_real_start, re, name_real_end }

        break
      end
    end
  end

  vim.api.nvim_buf_set_text(
    buf,
    mname_range[1],
    mname_range[2],
    mname_range[3],
    mname_range[4],
    { value }
  )
  return mname_range
end

M.root_modules_new = function(section, module_name)
  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)
  local ts_query = string.format(
    [[
(return_statement (expression_list
  (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor) @section_table; i want to get position of closing `}` and insert on line above.
      )
  ) (#eq? @section_key "%s")
))
]],
    section
  )
  local parsed = vim.treesitter.parse_query("lua", ts_query)
  local root = get_root(buf)

  for id, node, _ in parsed:iter_captures(root, buf, 0, -1) do
    local name = parsed.captures[id]
    local t = tsq.get_node_text(node, buf)
    local rs, cs, re, ce = node:range()
    if name == "section_table" then
      vim.api.nvim_buf_set_lines(buf, re, re, true, { '    "' .. module_name .. '",' })
    end
  end
end

M.root_modules_delete = function(section, module_name)
  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)

  local ts_query = string.format(
    [[
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
]],
    module_name,
    section
  )

  local parsed = vim.treesitter.parse_query("lua", ts_query)
  local root = get_root(buf)
  local mod_str_node
  local comment_nodes = {}
  local mname_range

  for id, node, _ in parsed:iter_captures(root, buf, 0, -1) do
    local name = parsed.captures[id]
    if name == "module_string" then
      mod_str_node = node
    elseif name == "section_comment" then
      table.insert(comment_nodes, node)
    end
  end

  if mod_str_node == nil and #comment_nodes == 0 then
    return false
  end

  -- TODO: find line and remove it

  if mod_str_node then
    local t = tsq.get_node_text(mod_str_node, buf)
    print("found string: ", t)
    local rs, cs, re, ce = mod_str_node:range()
    mname_range = { rs, cs + 1, re, ce - 1 }
  elseif #comment_nodes > 0 then
    for _, node in ipairs(comment_nodes) do
      local t = tsq.get_node_text(node, buf)
      local match_str = '--%s-"' .. module_name .. '",'

      -- find position of module name in the comment
      if string.match(t, match_str) then
        local start_pos = string.find(t, module_name)
        local end_pos = start_pos + string.len(module_name)
        local rs, cs, re, ce = node:range()
        local indentation = cs - 1
        local name_real_start = indentation + start_pos
        local name_real_end = indentation + end_pos
        mname_range = { rs, name_real_start, re, name_real_end }

        break
      end
    end
  end

  -- vim.api.nvim_buf_set_text(
  --   buf,
  --   mname_range[1],
  --   mname_range[2],
  --   mname_range[3],
  --   mname_range[4],
  --   { value }
  -- )
  return mname_range
end

M.root_modules_toggle = function(section, module_name)
  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)
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
