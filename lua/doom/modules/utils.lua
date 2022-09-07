local ts = require("doom.utils.ts")
local b = require("doom.utils.buf")
local queries = require("doom.utils.queries")
local rq = require("refactoring").queries

-- replace: get_query_capture ->  Query:new() from `refactoring.nvim`

-- HACK: ARCHITEXT
--
-- now that I have gotten a little bit comfortable with
-- queries I could look into using Architext for at least
-- one of operations on modules.

-- TODO: INJECT TSQ_TEMPL_ SO THAT ALL QUERY TEMPLATES CAN BE
--        kept in a nice table
--
--        tsq_templ_ -> highlight all containing strings
--
-- NOTE: if no module file passed ->>> operate on `./settings.lua`

local type_to_ts = {
  -- create mapping from lua to query atoms
  -- in order to automate query generation.
}

--
-- UTILS
--

local validate = function(opts)
  if not opts.action then
    return false
  end
  return true
end

local function get_ts_data_root_modules(msection, mname)
  local strings = {}
  if mname then
    strings = ts.get_query_capture(
      string.format(queries.ts_query_template_mod_string, mname, msection),
      "module_string"
    )
  end
  local comments = ts.get_query_capture(
    string.format(queries.ts_query_template_mod_comment, msection),
    "section_comment"
  )
  local tables, buf = ts.get_query_capture(
    string.format(queries.ts_query_template_section_table, msection),
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

-- local get_text = function(node, bufnr)
-- end

local M = {}

--[[----------------------
--   VALIDATE MODULES
----------------------]]

-- run this to make sure that all modules are exposed in the
-- root file.
M.sync_modules_to_root_file = function()
  -- reuse funcs from module CRUD here to
  -- insert modules.
end

M.validate_and_prettify_modules = function()
  -- A. check that components are structured in the correct order.
  -- B. make sure that there are very clear `comment_frames` that
  --      make it easy to follow where you are and which module you are
  --      looking at.
  -- C. Insert missing components if necessary.
end

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
    b.set_text(ts_state.buf, range, opts.new_name)
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
      b.set_text(ts_state.buf, range, '"' .. selected_mod)
    end
  end
end

--
-- SINGLE MODULE APPLY ACTIONS
--

-- redo all of this with function calls instead so that it looks nicer
M.module_apply = function(opts)
  if not validate(opts) then
    return
  end

  -- TODO: if module file is empty ??
  -- TODO: local compute_insertion_point = get_insertion_point_for_component()

  if opts.action == "component_add" then
    local captures, buf = ts.get_query_capture(
      queries.tsq_get_comp_containers(opts.add_component_sel),
      "comp_unit",
      opts.selected_module.path .. "init.lua"
    )

    if not #captures then
      return false
    end
    local insertion_line = captures[#captures].range[1]
    local insertion_col = captures[#captures].range[2]
    vim.api.nvim_win_set_buf(0, buf)
    vim.fn.cursor(insertion_line + 1, insertion_col + 1)

    --
  elseif opts.action == "component_edit_sel" then
    -- TODO: how pass scope to iter captures?
    -- TODO: use `refactoring.nvim` func here.
    -- TODO:
    --      1. get base table query.
    --      2. get component query
    --      3. pluck base table
    --      4. pluck component
    --      5. switch file. refactor???
    --      6. set cursor. refactor???

    -- local q_ = rq.new(opts.selected_module.path .. "init.lua")

    -- local captures, buf = ts.get_query_capture(
    --   queries.tsq_get_comp_selected(opts),
    --   "comp_unit",
    --   opts.selected_module.path .. "init.lua"
    -- )

    if not #captures then
      return false
    end

    --
  elseif opts.action == "component_remove_sel" then
    -- reuse same query as above

    --
  elseif opts.action == "component_replace_sel" then
    -- reuse same query as above

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
