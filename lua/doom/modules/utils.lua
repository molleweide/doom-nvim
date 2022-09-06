local utils = require("doom.utils")
local tsq = require("vim.treesitter.query")

-- TODO:
--
--    - split queries
--    - merge root module funcs into one
--    - sketch out component funcs.
--

-- HACK: ARCHITEXT
--
-- now that I have gotten a little bit comfortable with
-- queries I could look into using Architext for at least
-- one of operations on modules.

-- TODO: INJECT TSQ_TEMPL_ SO THAT ALL QUERY TEMPLATES CAN BE
--        kept in a nice table
--
--        tsq_templ_ -> highlight all containing strings

local type_to_ts = {
  -- create mapping from lua to query atoms
  -- in order to automate query generation.
}

--
-- UTILS
--

local validate = function(opts) end

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

  return t, buf
end

local function get_ts_data_root_modules(msection, mname)
  local strings = {}
  if mname then
    strings = get_query_capture(
      string.format(ts_query_template_mod_string, mname, msection),
      "module_string"
    )
  end
  local comments = get_query_capture(
    string.format(ts_query_template_mod_comment, msection),
    "section_comment"
  )
  local tables, buf = get_query_capture(
    string.format(ts_query_template_section_table, msection),
    "section_table"
  )
  return {
    ts = {
      strings = strings,
      comments = comments,
      tables = tables,
    },
    buf = buf,
  }
end

local function get_replacement_range(strings, comments, module_name, buf)
  if strings[1] then
    return {
      strings[1].range[1],
      strings[1].range[2] + 1,
      strings[1].range[3],
      strings[1].range[4] - 1,
    },
      true
  else
    for _, node in ipairs(comments) do
      local match_str = '--%s-"' .. module_name .. '",'

      -- find position of module name in the comment
      if string.match(node.text, match_str) then
        local start_pos = string.find(node.text, module_name)
        local end_pos = start_pos + string.len(module_name)
        local indentation = node.range[2] - 1
        local name_real_start = indentation + start_pos
        local name_real_end = indentation + end_pos
        return { node.range[1], name_real_start, node.range[3], name_real_end },
          false,
          node.range[2]
      end
    end
  end
end

--
-- NVIM BUF HELPERS
--

local function replace_lines(buf, line, value)
  if type(value) == "string" then
    -- replace single line
  elseif type(value) == "table" then
    -- replace mult lines
  end
end

local function replace_text() end
local function delete_lines(buf, start, end_)
  if end_ then
  else
    -- delete line start.
  end
end

local function insert_lines(buf, line, value)
  -- before/after
  --
  -- string or #table == 1 / else loop mult lines
end

local function set_lines(buf, line, start, end_, value) end

local function insert_line(buf, line, value)
  vim.api.nvim_buf_set_lines(buf, line, line, true, { value })
end

-- local function replace_line(buf, line, value) end

local function set_text(buf, range, value)
  vim.api.nvim_buf_set_text(buf, range[1], range[2], range[3], range[4], { value })
end

local function insert_text_at(buf, row, col, value)
  vim.api.nvim_buf_set_text(buf, row, col, row, col, { value })
end

-- local get_text = function(node, bufnr)
-- end

--
-- ROOT MODULES QUERIES
--

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
        value: (table_constructor) @section_table)
  ) (#eq? @section_key "%s")
))
]]

local M = {}

--
-- ROOT MODULES TS FUNCTIONS
--

-- RENAME: root_modules_apply
M.root_apply = function(opts)
  local selected_mod
  if opts.module_name ~= nil then
    selected_mod = opts.module_name
  end
  local ts_state = get_ts_data_root_modules(opts.section, selected_mod)
  if not ts_state.ts.strings[1] and not ts_state.ts.comments[1] then
    return false
  end
  local range, enabled, comment_start
  if opts.action ~= "new" then
    range, enabled, comment_start = get_replacement_range(
      ts_state.ts.strings,
      ts_state.ts.comments,
      selected_mod,
      ts_state.buf
    )
  end
  if opts.action == "rename" then
    set_text(ts_state.buf, range, opts.new_name)
  elseif opts.action == "new" then
    local pre = '    "'
    local post = '",'
    insert_line(ts_state.buf, ts_state.ts.tables[1].range[3], pre .. opts.new_name .. post)
  elseif opts.action == "delete" then
    vim.api.nvim_buf_set_lines(ts_state.buf, range[1], range[1] + 1, 0, {})
  elseif opts.action == "toggle" then
    if enabled then
      insert_text_at(ts_state.buf, range[1], range[2] - 1, "-- ")
    else
      range[2] = comment_start
      set_text(ts_state.buf, range, '"' .. selected_mod)
    end
  end
end

--
-- MODULE QUERIES
--

-- types of funcs
--
--     get_component table
--     get_child_table
--     get_component_entry_by_data
--          pkg spec -> by name string
--          bind tbl -> by unique prop combo

-- pass (settings|packages|configs|cmds|autocmds|binds)
-- return query for container table
local tsq_get_last_component_of_type = function(component)
  local ts_query_components_table
  if component == "config" then
    ts_query_components_table = string.format(
      [[
(assignment_statement
  (variable_list
    name: (bracket_index_expression
        table: (dot_index_expression
          table: (identifier)
          field: (identifier))
        field: (string)
    )
  )
  (expression_list
    value: (function_definition
      parameters: (parameters))
  )
)
  ]],
      component
    )
  else
    ts_query_components_table = string.format(
      [[
  (assignment_statement
    (variable_list
      name:
        (dot_index_expression
          table: (identifier)
          field: (identifier) @i
        )
    )(#eq? @i "%s")
    ( expression_list
      value: (table_constructor) @components_table
    )
  )
  ]],
      component
    )
  end

  return ts_query_components_table
end

local mod_get_settings_leaf = function(leaf_data)
  -- NOTE: if no module file passed ->>> operate on `./settings.lua`

  -- compute query based on settings leaf type.
end

-- TODO: injections > string.format inside of a function = `^tsq_`
local mod_get_query_for_child_table = function(components, child_specs)
  -- use for:
  --  packages; cmds; autocmds; binds
  local ts_query_child_table = string.format(
    [[
(assignment_statement
  (variable_list
      name:
        (dot_index_expression
          table: (identifier)
          field: (identifier) @i
        )
  )
  ( expression_list
    value: (table_constructor
      (field
        name: ( string ) @s2
        value: ( table_constructor ) @t2
      )
    ) @components_table
  )
)(#eq? @i "packages")
]],
    components
  )
end

local mod_get_query_for_bind = function()

  -- I assume that all binds are unique so it should be possible
  -- to make a single query quite easy to get explicit ranges
  -- for a single table.

  -- HACK: THIS IS ACTUALLY GOING TO BE SO MUCH FUN TO FIX THIS.

  -- recieve data here and inspect what I need in order to
  -- see what kinds of queries I can make.

  -- should work for any bind.
  -- so this one has to be flexible.
end

local ts_query_mod_get_pkg_spec = function(pkg_name)
  -- get package spec query by name.
  local ts_query = string.format([[
()
]])
end

local ts_query_mod_get_pkg_config = [[
()
]]

local ts_query_mod_get_cmd = [[
()
]]

local ts_query_autocmd_table = [[
()
]]

local ts_query_bind_table = [[
()
]]

--
-- MODULE APPLY ACTIONS
--

M.module_apply = function(opts)
  if opts.action == "component_add" then
    -- print(vim.inspect(opts.selected_component))

    -- TODO: make helper if not validate(opts) then return end
    --    which makes sure that we got everything we need
    if not validate(opts) then
      return
    end

    -- if module file is empty ??

    local query =string.format(ts_query_template_mod_string, mname, msection)

    local buf = utils.get_buf_handle(opts.selected_module.path)

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

    print(vim.inspect(t))

    -- if not captures then
    --   local compute_insertion_point = get_insertion_point_for_component()
    -- end

    -- set buf > move curser > enter insert mode.

  elseif opts.action == "component_edit_sel" then
    -- put cursor at beginning of selected component
  elseif opts.action == "component_remove_sel" then
    -- put cursor at beginning of selected component
  elseif opts.action == "component_replace_sel" then
    -- put cursor at beginning of selected component
  elseif opts.action == "pkg_fork" then
    -- put cursor...
  elseif opts.action == "pkg_clone" then
    -- put cursor...
  elseif opts.action == "pkg_cfg_add" then
    -- put cursor at insertion point...
  elseif opts.action == "bind_leader_add" then
  elseif opts.action == "bind_leader_add_to_sel" then
  elseif opts.action == "bind_" then
  end
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
