local log = require("doom.utils.logging")
local utils = require("doom.utils")
local spec = require("doom.core.spec")
local tree = require("doom.utils.tree")
local tscan = require("doom.utils.tree").traverse_table
local templ = require("doom.utils.templates")
local ts = require("doom.utils.ts")
local b = require("doom.utils.buf")
local q = require("doom.utils.queries")
local nt = require("nvim-treesitter.utils")

-- TODO: apply formatting to file operated on. call null-ls method on buf.
--
-- TODO: add debug logs and messages
--

local compute_insertion_point = function() end

local rmf = utils.find_config("modules.lua")

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

-- local validate = function(opts)
--   -- DOESN'T DO MUCH AT THE MOMENT. DUNNO IF THIS IS NECESSARY ATM.
--   --
--   -- todo: check what types of components a module contain so that we
--   -- can make conditionals based on this. Eg.
--   if not opts.action then
--     return false
--   end
--   return true
-- end

-- todo
--
--    - insert before/after
--
local function act_on_capture(captures, buf)
  -- TODO: USE THIS FUNCTION IN NVIM-TREESITTER.
  --
  --  PR: add the ability to pass a buf handle
  --
  -- goto_node(node, goto_end, avoid_set_jump)~
  -- Sets cursor to the position of `node` in the current windows.

  if #captures > 0 then
    if doom.settings.doom_ui.insert_templates == "templates" then
      -- insert template
    elseif doom.settings.doom_ui.use == "luasnip" then
      -- init luasnippet
    else
      -- only move cursor
      b.set_cursor_to_buf(buf, captures[#captures].range)
    end
  end
end

local function get_settings_file(mod_path)
  if mod_path then
    return mod_path .. "init.lua"
  else
    return utils.find_config("settings.lua")
  end
end

local function has_leader(opts, capture)
  local leader, buf = ts.get_captures(
    opts.selected_module.path .. "init.lua",
    q.leader_t,
    capture or "leader_field"
  )
  return leader, buf
end

local function find_deepest_leader()

  -- get_next_node(node, allow_switch_parent, allow_next_parent)~
  -- Returns the next node within the same parent.

  -- get_previous_node(node, allow_switch_parents, allow_prev_parent)~
  -- Returns the previous node within the same parent.

  -- get_named_children(node)~
  -- Returns a table of named children of `node`.

  ------------------------------------------------------------------

  -- while(leader_tbl)
  -- do
  --    -- assumes no duplicate branches
  --    checks for child table with correct "lhs"
  --    loop children
  --
  --    leader_tbl = ...
  -- end
end

local function build_new_bind()
  -- BUILD NEW LEADER
  --
  --
  --      create helper func
  --
  --      generate dummy branch names
  --          +AAA, +BBB, +CCC, ...
end

local function get_branch_from_leader_bind() end

local function get_branch_node_under_cursor()
  -- 1. nvim treesitter get node under cursor.
  -- 2. iterate outwards.
  -- 3. check for match pattern with spec.
  -- 4. if match return most logical enclosing node
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
    leaf = function(_, _, v)
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

mod_util.root_new = function(opts)
  local tables, buf = ts.get_captures(rmf, q.root_section(opts.section), "section_table")
  local nt = #tables
  b.insert_line(buf, tables[nt].range[3], '    "' .. opts.new_name .. '",')
end

mod_util.root_rename = function(opts)
  local strings = ts.get_captures(rmf, q.root_mod(opts.module_name, opts.section), "module_string")
  local comments, buf = ts.get_captures(rmf, q.root_comments(opts.section), "section_comment")
  local range, enabled, comment_start = get_replacement_range(
    strings,
    comments,
    opts.module_name,
    buf
  )
  b.set_text(buf, range, opts.new_name)
end

mod_util.root_delete = function(opts)
  local strings = ts.get_captures(rmf, q.root_mod(opts.module_name, opts.section), "module_string")
  local comments, buf = ts.get_captures(rmf, q.root_comments(opts.section), "section_comment")
  local range, enabled, comment_start = get_replacement_range(strings, comments, selected_mod, buf)
  vim.api.nvim_buf_set_lines(buf, range[1], range[1] + 1, 0, {})
end

mod_util.root_toggle = function(opts)
  local strings = ts.get_captures(rmf, q.root_mod(opts.module_name, opts.section), "module_string")
  local comments, buf = ts.get_captures(rmf, q.root_comments(opts.section), "section_comment")
  local range, enabled, comment_start = get_replacement_range(
    strings,
    comments,
    opts.module_name,
    buf
  )

  if enabled then
    b.insert_text_at(buf, range[1], range[2] - 1, "-- ")
  else
    range[2] = comment_start
    b.set_text(buf, range, '"' .. opts.module_name)
  end
end

--
-- SETTINGS
--

mod_util.setting_add = function(opts)
  act_on_capture(
    ts.get_captures(
      get_settings_file(opts.selected_module),
      q.mod_tbl(opts.ui_input_comp_type),
      "rhs"
    )
  )
end

mod_util.setting_edit = function(opts)
  local sc = opts.selected_component
  act_on_capture(
    ts.get_captures(
      get_settings_file(opts.selected_module),
      q.mod_tbl(sc.component_type),
      "rhs",
      q.field(sc.data.table_path[#sc.data.table_path], sc.data.table_value),
      "value"
    )
  )
end

mod_util.setting_add_to_selection_level = function()
  -- allows you to select a sub table entry and add a new entry to
  -- the same sub table
end

mod_util.setting_move = function(opts) end

mod_util.setting_remove = function(opts) end

mod_util.setting_replace = function(opts) end

--
-- PACKAGES
--

mod_util.package_add = function(opts)
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.selected_component.component_type),
      "rhs"
    )
  )
end

mod_util.package_edit = function(opts)
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.selected_component.component_type),
      "rhs",
      q.pkg_table(opts.selected_component.data.table_path, opts.selected_component.data.spec[1]),
      "pkg_table"
    )
  )
end

mod_util.package_move = function(opts) end
mod_util.package_remove = function(opts) end
mod_util.package_clone = function(opts) end
mod_util.package_fork = function(opts) end
mod_util.package_toggle_local = function(opts) end
mod_util.package_use_specific_upstream = function(opts) end

mod_util.create_new_module_from = function()
  -- package string / section
  -- or other compones.
  -- spawn new module and enter it etc.
end

--
-- CONFIGS
--

-- 1. check if config table exists
-- 2. add table after
--        - settings
--      and before
--        - standalone config functions > need to check if these exist
--              also check if the target pkg already has a standalone func.
--        - before cmds/autocmds/binds
--
mod_util.config_add = function(opts)
  local captures, buf = ts.get_captures(
    opts.selected_module.path .. "init.lua",
    q.config_func(),
    "rhs"
  )
  act_on_capture(captures, buf)
end

mod_util.config_edit = function(opts)
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.config_func(opts.selected_component.data),
      "rhs"
    )
  )
end

mod_util.config_remove = function(opts) end
mod_util.config_replace = function(opts) end

--
-- CMDS
--

mod_util.cmd_add = function(opts)
  -- print(vim.inspect(opts.selected_component))
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.selected_component.component_type),
      "rhs"
    )
  )
end

mod_util.cmd_edit = function(opts)
  act_on_capture(
    ts.get_captures(
      q.mod_tbl(opts.selected_module.path .. "init.lua", opts.selected_component.component_type),
      "rhs",
      q.cmd_table(opts.selected_component.data),
      "action"
    )
  )
end

mod_util.cmd_remove = function(opts) end
mod_util.cmd_replace = function(opts) end
mod_util.cmd_move = function(opts) end

--
-- AUTOCMDS
--

mod_util.autocmd_add = function(opts)
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.ui_input_comp_type),
      "rhs"
    )
  )
end

mod_util.autocmd_edit = function(opts)
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.ui_input_comp_type),
      "rhs",
      q.autocmd_table(opts.selected_component.data),
      "action"
    )
  )
end

mod_util.autocmd_remove = function(opts) end
mod_util.autocmd_replace = function(opts) end
mod_util.autocmd_move = function(opts) end

--
-- BINDS
--

mod_util.bind_add = function(opts)
  local t, buf = ts.get_captures(
    opts.selected_module.path .. "init.lua",
    q.mod_tbl(opts.selected_component.component_type),
    "rhs"
  )

  local leader = has_leader(opts)
  if #leader > 0 then
    act_on_capture(leader, buf)
  else
    act_on_capture(t, buf)
  end
end

mod_util.bind_add_after = function(opts)
  -- TELESCOPE  -> then get the bind under cursor with queries
  -- REGULAR    -> get bind / enclosing with nvim treesitter cursor helpers.
  local binds_tbl, bind, buf = ts.get_captures(
    opts.selected_module.path .. "init.lua",
    q.mod_tbl(opts.selected_component.component_type),
    "rhs",
    q.binds_table(opts.selected_component.data),
    "rhs"
  )
  local leader = has_leader(opts, "leader_table")
  local add_new_leader = nt.is_parent(leader[1].node, bind[1].node) -- Nodes
  if add_new_leader then
    local branch_table = get_branch_from_leader_bind(bind[1].node)
    -- insert new bind above row_end
  else
    -- insert line after bind and before leader if leader
  end
end

mod_util.bind_edit = function(opts)
  -- print(vim.inspect(opts.selected_component))
  act_on_capture(
    ts.get_captures(
      opts.selected_module.path .. "init.lua",
      q.mod_tbl(opts.selected_component.component_type),
      "rhs",
      q.binds_table(opts.selected_component.data),
      "rhs"
    )
  )
end

mod_util.bind_add_to_selection_level = function(opts) end

mod_util.bind_add_to_level = function(opts) end

mod_util.bind_remove = function(opts) end

mod_util.bind_replace = function(opts) end

mod_util.bind_move = function(opts) end

mod_util.bind_create_from_line = function(opts)
  local binds_table, buf = ts.get_captures(
    opts.selected_module.path .. "init.lua",
    q.mod_tbl(opts.ui_input_comp_type),
    "rhs"
  )
  local line = opts.line
  local match_leader = line:match("^%s*")
  local lhs_str = line.sub(white_space_range)
  print("`" .. match_leader .. "`")

  local leader = has_leader(opts, "leader_table")

  local leader_tbl
  if leader[1] then
    leader_tbl = leader[1].node
    local branch_target, new_lhs_subtracted = find_deepest_leader(leader_tbl, lhs_str)
  end
  local bind_new_compiled_str = build_new_bind()
  -- it feels like this whole if statement could be
  -- refactored into somekind of binds_insert helper
  if #leader > 0 then
    if is_leader then
      --    append new leader bind
    else
      --    insert after leader here.
    end
  else
    if is_leader then
      --    need to create whole new leader table here.
    else
      --    just insert here
    end
  end
end

mod_util.bind_move_leader = function(opts)
  -- make it more easy to manage binds
end

mod_util.bind_add_to_same = function(opts) end

mod_util.bind_make_leader = function(opts)
  -- create a loop that generates the leader.
  --
  -- leader_max_length
end

mod_util.bind_merge_leader = function(opts) end

--
-- GET FULL/EXTENDED TABLE OF ALL MODULES
--

-- FUTURE: filter levels instead -> since you might have a recursive module structure?
--    so that we don't need (origins/sections/mname) hardcoded -> used tree traversal instead.

-- can I shoe horn the usage of metatables into this file just so that I force myself to learn them?

mod_util.extend = function(filter)
  -- todo: use system.config path here
  local config_path = vim.fn.stdpath("config")

  -- todo: append "init.lua" so that we know that we only get module
  local function glob_modules(cat)
    if not vim.tbl_contains(spec.origins, cat) then
      return
    end
    local glob = config_path .. "/lua/" .. cat .. "/modules/" .. spec.modules_max_depth
    return vim.split(vim.fn.glob(glob), "\n")
  end

  local glob_doom_modules = glob_modules("doom")
  local glob_user_modules = glob_modules("user")
  local all = glob_doom_modules
  for _, p in ipairs(glob_user_modules) do
    table.insert(all, p)
  end

  local m_all = { doom = {}, user = {} }
  for _, p in ipairs(all) do
    local m_origin, m_section, m_name = p:match("/([_%w]-)/modules/([_%w]-)/([_%w]-)/$")
    if m_origin == nil then
      m_origin = "user" -- todo: WHY IS ORIGIN NIL HERE FOR USER??
    end
    tree.attach_table_path(m_all[m_origin], { m_section, m_name }, {
      type = "doom_module_single", -- todo: how is type used?
      enabled = false,
      name = m_name,
      section = m_section,
      origin = m_origin,
      path = p, -- only the dir path
      -- path_init = module init file path
    })
  end

  -- add_enabled_states
  tree.traverse_table({
    tree = require("doom.core.modules").enabled_modules,
    leaf = function(stack, _, v)
      local pc, path_concat = tree.flatten_stack(stack, v, ".")
      for _, path in ipairs(spec.search_paths(path_concat)) do
        local origin = path:sub(1, 4)
        local m = tree.attach_table_path(m_all[origin], pc)
        if m then
          m.enabled = true
          for i, j in pairs(tree.attach_table_path(doom.modules, pc)) do
            m[i] = j
          end
        end
      end
    end,
  })

  -- local function apply_filters(mods)
  --   -- AND type(filter) == "table"
  --   if filter and type(filter) == "table" then
  --     if filter.origins then
  --       for o, origin in pairs(mods) do
  --         if vim.tbl_contains(filter.origins, o) then
  --           table.remove(mods, o) -- filter origins
  --         else
  --           for s, section in pairs(origin) do
  --             if not vim.tbl_contains(filter.sections, s) then
  --               table.remove(mods[o], s) -- filter sections
  --             else
  --               for m, _ in pairs(section) do
  --                 if m.enabled ~= filter.enabled or not vim.tbl_contains(filter.names, m) then
  --                   table.remove(mods[o][s], m) -- filter modules by name
  --                 end
  --               end
  --             end
  --           end
  --         end
  --       end
  --     end
  --   end
  --   return mods
  -- end

  return m_all
end

return mod_util
