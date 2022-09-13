local tscan = require("doom.utils.tree").traverse_table
local templ = require("doom.utils.templates")
local ts = require("doom.utils.ts")
local b = require("doom.utils.buf")
local queries = require("doom.utils.queries")

-- local Query = require("refactoring").query
-- replace: get_query_capture ->  Query:new() from `refactoring.nvim`

-- note: if no module file passed ->>> operate on `./settings.lua`

-- doesn't do much at the moment. dunno if this is necessary atm.
local validate = function(opts)
  -- todo: check what types of components a module contain so that we
  -- can make conditionals based on this. Eg.
  if not opts.action then
    return false
  end
  return true
end

local compute_insertion_point = function() end

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

local mod_util = {}

mod_util.modules_refactor = function()
  -- eg. if you have
  -- mod_x.configs["arst"] = function() end
  --
  -- transform this into a regular table where all functions
  -- are kept inside of it??
end

-- run this to make sure that all modules are exposed in the
-- root file.
mod_util.sync_modules_to_root_file = function()
  -- reuse funcs from module CRUD here to
  -- insert modules.
end

mod_util.module_move_all_component_function_into_table = function()
  -- if you have
  -- mod.xx["xx"]  = func
  --  move this into mod.xx = { ["xx"] = func, ["yy"] = ....}
end

mod_util.validate_and_prettify_modules = function()
  -- A. check that components are structured in the correct order.
  -- B. make sure that there are very clear `comment_frames` that
  --      make it easy to follow where you are and which module you are
  --      looking at.
  -- C. Insert missing components if necessary.
end

-- todo: branch check origin/section/category
mod_util.check_if_module_name_exists = function(m, new_name)
  -- local orig = type(m) == "string" and m or m.section
  -- local sec = type(m) == "string" and m or m.section
  local results = tscan({
    tree = require("doom.modules.utils").extend(),
    filter = "doom_module_single", -- what makes a node in the tree
    node = function(_, _, v)
      -- todo: if m == string then do
      --
      if m.section == v.section and v.name == new_name then
        log.debug("dui/actions check_if_module_exists: true")
        return true
      end
    end,
  })
  return false
end

-- crud operations for `modules.lua`
-- REFACTOR: i am not satisfied
mod_util.root_apply = function(opts)
  local function get_ts_data_root_modules(msection, mname)
    local strings = {}
    if mname then
      strings = ts.get_query_capture(
        queries.root_mod_name_by_section(mname, msection),
        "module_string"
      )
    end
    local comments = ts.get_query_capture(
      queries.root_all_comments_from_section(msection),
      "section_comment"
    )
    local tables, buf = ts.get_query_capture(
      queries.root_get_section_table_by_name(msection),
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
    b.insert_line(ts_state.buf, ts_state.ts.tables[1].range[3], pre .. opts.new_name .. post)
  elseif opts.action == "delete" then
    vim.api.nvim_buf_set_lines(ts_state.buf, range[1], range[1] + 1, 0, {})
  elseif opts.action == "toggle" then
    if enabled then
      b.insert_text_at(ts_state.buf, range[1], range[2] - 1, "-- ")
    else
      range[2] = comment_start
      b.set_text(ts_state.buf, range, '"' .. selected_mod)
    end
  end
end

--
-- SETTINGS
--

mod_util.setting_add = function(opts)
  -- adds a new root setting to the settings table.
  -- IF no module selected -> operates on `./modules.lua`
  local captures, buf = ts.get_query_capture(
    queries.assignment_statement("table", opts.ui_input_comp_type),
    "rhs",
    opts.selected_module.path .. "init.lua"
  )
  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)
  -- TODO: INSERT COMPONENT TEMPLATE HERE
  -- as the last thing of the same type
  -- templ.<comp>
end

-- mod_util.setting_add_to_selection_level = function()
--   -- allows you to select a sub table entry and add a new entry to
--   -- the same sub table
-- end

mod_util.setting_edit = function(opts)
  -- put cursor at last pos of setting and insert
  -- print()
  local sc = opts.selected_component
  local mf = opts.selected_module.path .. "init.lua"

  local q_comp_table_rhs = queries.assignment_statement("table", sc.component_type)
  local q_settings_field = queries.field(
    sc.data.table_path[#sc.data.table_path],
    sc.data.table_value
  )

  local c_containers, buf = ts.get_query_capture(q_comp_table_rhs, "rhs", mf)

  print("CONT:", q_comp_table_rhs)
  print("UNIT:", q_settings_field)
  print("captures:", #c_containers)

  local captures, buf = ts.get_query_capture(q_settings_field, "value", mf)

  print("captures:", #captures)

  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)

  -- TODO: visually select option here
end
-- mod_util.setting_move = function(opts) end
-- mod_util.setting_remove = function(opts) end
-- mod_util.setting_replace = function(opts) end

--
-- PACKAGES
--

mod_util.package_add = function(opts)
  local captures, buf = ts.get_query_capture(
    queries.assignment_statement("table", opts.ui_input_comp_type),
    "rhs",
    opts.selected_module.path .. "init.lua"
  )
  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end

mod_util.package_edit = function(opts)
  -- local sc = opts.selected_component.value
  local mf = opts.selected_module.path .. "init.lua"

  print(vim.inspect(opts.selected_component))

  local q_comp_table_rhs = queries.assignment_statement(
    "table",
    opts.selected_component.component_type
  )
  local q_pkg_table = queries.pkg_table(
    opts.selected_component.data.table_path,
    opts.selected_component.data.spec[1]
  )

  local c_containers, buf = ts.get_query_capture(q_comp_table_rhs, "rhs", mf)
  -- print("pkg b:", q_comp_table_rhs)
  -- print("pkg t:", q_pkg_table)
  -- print("captures:", #c_containers)
  local captures, buf = ts.get_query_capture(
    q_pkg_table,
    "pkg_table",
    opts.selected_module.path .. "init.lua"
  )

  -- print("captures:", #captures)

  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end

-- mod_util.package_move = function(opts) end
-- mod_util.package_remove = function(opts) end
-- mod_util.package_clone = function(opts) end
-- mod_util.package_fork = function(opts) end
-- mod_util.package_toggle_local = function(opts) end
-- mod_util.package_use_specific_upstream = function(opts) end

--
-- CONFIGS
--

mod_util.config_add = function(opts)
  -- 1. check if config table exists
  -- 2. add table after
  --        - settings
  --      and before
  --        - standalone config functions > need to check if these exist
  --              also check if the target pkg already has a standalone func.
  --        - before cmds/autocmds/binds
  --
  local captures, buf = ts.get_query_capture(
    queries.assignment_statement("func", opts.ui_input_comp_type),
    "rhs",
    opts.selected_module.path .. "init.lua"
  )
  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end

mod_util.config_edit = function(opts)
  -- TODO: TRY EXTENDING THE TABLE FROM HERE AND SEE HOW IT GOES
  --
  --
  --    i need to extend the

  local captures, buf = ts.get_query_capture(
    queries.assignment_statement("func", opts.ui_input_comp_type),
    "rhs",
    opts.selected_module.path .. "init.lua"
  )
  if not #captures then
    return false
  end
  local insertion_line = captures[#captures].range[1]
  local insertion_col = captures[#captures].range[2]
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end
-- mod_util.config_remove = function(opts) end
-- mod_util.config_replace = function(opts) end

--
-- CMDS
--

mod_util.cmd_add = function(opts) end
mod_util.cmd_edit = function(opts)
  -- local sc = opts.selected_component.value
  local mf = opts.selected_module.path .. "init.lua"

  print(vim.inspect(opts.selected_component))

  local q_comp_table_rhs = queries.assignment_statement(
    "table",
    opts.selected_component.component_type
  )
  local q_cmd_table = queries.cmd_table(opts.selected_component)

  -- local c_containers, buf = ts.get_query_capture(q_comp_table_rhs, "rhs", mf)
  --
  -- -- print("pkg b:", q_comp_table_rhs)
  -- -- print("pkg t:", q_pkg_table)
  -- -- print("captures:", #c_containers)
  --
  -- local captures, buf = ts.get_query_capture(
  --   q_pkg_table,
  --   "pkg_table",
  --   opts.selected_module.path .. "init.lua"
  -- )
  --
  -- -- print("captures:", #captures)
  --
  -- if not #captures then
  --   return false
  -- end
  -- local insertion_line = captures[#captures].range[1]
  -- local insertion_col = captures[#captures].range[2]
  -- vim.api.nvim_win_set_buf(0, buf)
  -- vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end
-- mod_util.cmd_remove = function(opts) end
-- mod_util.cmd_replace = function(opts) end
-- mod_util.cmd_move = function(opts) end

--
-- AUTOCMDS
--

mod_util.autocmd_add = function(opts)
  -- autocmd container
  local captures, buf = ts.get_query_capture(
    queries.assignment_statement("table", opts.ui_input_comp_type),
    "rhs",
    opts.selected_module.path .. "init.lua"
  )

  -- if not #captures then
  --   return false
  -- end
  -- local insertion_line = captures[#captures].range[1]
  -- local insertion_col = captures[#captures].range[2]
  -- vim.api.nvim_win_set_buf(0, buf)
  -- vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end

mod_util.autocmd_edit = function(opts)
  local mf = opts.selected_module.path .. "init.lua"
  -- print(vim.inspect(opts.selected_component))

  local q_comp_table_rhs = queries.assignment_statement(
    "table",
    opts.selected_component.component_type
  )

  -- todo: supply params
  local q_autocmd_table = queries.autocmd_table(opts.selected_component)
end

-- mod_util.autocmd_remove = function(opts) end
-- mod_util.autocmd_replace = function(opts) end
-- mod_util.autocmd_move = function(opts) end

--
-- BINDS
--

mod_util.bind_add = function(opts)

  -- 1. get binds table.
  -- 2. check if leader is present and where it is.
  -- 3. insert befor the leader

  -- local captures, buf = ts.get_query_capture(
  --   queries.assignment_statement("table", opts.ui_input_comp_type),
  --   "rhs",
  --   opts.selected_module.path .. "init.lua"
  -- )
  -- if not #captures then
  --   return false
  -- end
  -- local insertion_line = captures[#captures].range[1]
  -- local insertion_col = captures[#captures].range[2]
  -- vim.api.nvim_win_set_buf(0, buf)
  -- vim.fn.cursor(insertion_line + 1, insertion_col + 1)
end

-- mod_util.bind_add_to_selection_level = function(opts) end
-- mod_util.bind_add_to_level = function(opts) end

mod_util.bind_edit = function(opts)
  -- edit insert mode at rhs currently
  -- local sc = opts.selected_component.value
  local mf = opts.selected_module.path .. "init.lua"

  print(vim.inspect(opts.selected_component))

  local q_comp_table_rhs = queries.assignment_statement(
    "table",
    opts.selected_component.component_type
  )

  local q_binds_tbl = queries.binds_table(opts.selected_component)
end

-- mod_util.bind_remove = function(opts) end
-- mod_util.bind_replace = function(opts) end
-- mod_util.bind_move = function(opts) end
-- mod_util.bind_move_leader = function(opts)
--   -- make it more easy to manage binds
-- end

-- -- TODO: SPLIT INTO FUNCTIONS
-- mod_util.add_component = function(opts)
--   if not validate(opts) then
--     return
--   end
--
--   local q1 = queries.assignment_statement("table", opts.ui_input_comp_type)
--   local captures, buf = ts.get_query_capture(q1, "rhs", opts.selected_module.path .. "init.lua")
--
--   if not #captures then
--     return false
--   end
--   local insertion_line = captures[#captures].range[1]
--   local insertion_col = captures[#captures].range[2]
--
--   vim.api.nvim_win_set_buf(0, buf)
--   vim.fn.cursor(insertion_line + 1, insertion_col + 1)
--
--   -- TODO: INSERT COMPONENT TEMPLATE HERE
--   -- as the last thing of the same type
--   -- templ.<comp>
--
--
--   -- TODO: IF STATEMENT FOR EACH COMPOENENT TYPE
--
--
--
--
--   --   --
--   -- if opts.action == "component_edit_sel" then
--   --   local q_cont = queries.assignment_statement(
--   --     "table",
--   --     opts.selected_component.value.component_type
--   --   )
--   --   local q_unit = queries.comp_unit(opts.selected_component.value)
--   --
--   --   local c_containers, buf = ts.get_query_capture(
--   --     q_cont,
--   --     "rhs",
--   --     opts.selected_module.path .. "init.lua"
--   --   )
--   --
--   --   print("CONT:", q_cont)
--   --   print("UNIT:", q_unit)
--   --   print("captures:", #c_containers)
--   --
--   --   local captures, buf = ts.get_query_capture(
--   --     q_unit,
--   --     "value",
--   --     opts.selected_module.path .. "init.lua"
--   --   )
--   --
--   --   print("captures:", #captures)
--   --
--   --   if not #captures then
--   --     return false
--   --   end
--   --   local insertion_line = captures[#captures].range[1]
--   --   local insertion_col = captures[#captures].range[2]
--   --   vim.api.nvim_win_set_buf(0, buf)
--   --   vim.fn.cursor(insertion_line + 1, insertion_col + 1)
--   --
--   --   -- TODO: visually select option here
--   --
--   --   --
--   -- elseif opts.action == "component_remove_sel" then
--   --   -- REQUIRES YES/NO!!!
--   --
--   --   -- this should be easy -> just set range to empty string ""
--   --
--   --   --
--   -- elseif opts.action == "component_replace_sel" then
--   --
--   --   --
--   --   --  1. nui -> input entry
--   --   --
--   --   --  OR
--   --   --
--   --   --  2. move cursor and enter insert mode
--   --
--   --   -- put cursor at beginning of selected component
--   -- elseif opts.action == "pkg_fork" then
--   --   -- put cursor...
--   -- elseif opts.action == "pkg_clone" then
--   --   -- put cursor...
--   -- elseif opts.action == "pkg_cfg_add" then
--   --   -- put cursor at insertion point...
--   -- elseif opts.action == "bind_leader_add" then
--   -- elseif opts.action == "bind_leader_add_to_sel" then
--   -- elseif opts.action == "bind_" then
--   -- end
-- end

--
-- GET FULL/EXTENDED TABLE OF ALL MODULES
--

-- FUTURE: filter levels instead -> since you might have a recursive module structure?
--    so that we don't need (origins/sections/mname) hardcoded -> used tree traversal instead.

-- can I shoe horn the usage of metatables into this file just so that I force myself to learn them?

mod_util.extend = function(filter)
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

return mod_util
