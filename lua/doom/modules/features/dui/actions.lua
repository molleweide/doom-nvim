local utils = require("doom.utils")
local log = require("doom.utils.logging")
local system = require("doom.core.system")
local tscan = require("doom.utils.tree").traverse_table

-- local sh = require("user.modules.features.dui2.shell")
local nui = require("doom.modules.features.dui.nui")

-- video:
--    tj embedded formatting:    https://www.youtube.com/watch?v=v3o9YaHBM4Q
--    tj execute anything:       https://www.youtube.com/watch?v=9gUatBHuXE0
--    tj and vigoux:             https://www.youtube.com/watch?v=SMt-L2xf-10

-- TODO:
--
--    - fix `check_if_module_name_exists` with `extend()`
--    - make sure I have access to all necessary data in each method
--    - play around with nui dimensions

--  - open/edit (new) module in split / same win is default on <CR>

local actions = {}
local conf_ui = {}

conf_ui.settings = {
  confirm_alternatives = { "yes", "no" },
  section_alternatives = { "user", "features", "langs", "core" },
  popup = {
    relative = "cursor",
    position = {
      row = 1,
      col = 0,
    },
    size = 20,
    border = {
      style = "rounded",
      text = {
        top = "[Input]",
        top_align = "left",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  },
  menu = {
    position = "20%",
    size = {
      width = 20,
      height = 2,
    },
    relative = "editor",
    border = {
      style = "single",
      text = {
        top = "Choose Something",
        top_align = "center",
      },
    },
    win_options = {
      winblend = 10,
      winhighlight = "Normal:Normal",
    },
  },
}
local confirm_alternatives = { "yes", "no" }

-- -- c, m, new_name
-- local function check_if_module_name_exists(c, m, new_name)
--   local already_exists = false
--   for _, v in pairs(c.entries_mapped) do
--     if v.section == m.section and v.name == new_name then
--       already_exists = true
--     end
--   end
--   return already_exists
-- end

local function check_if_module_name_exists(m, new_name)
  -- TODO: need to account for origin.
  -- local orig = type(m) == "string" and m or m.section
  local sec = type(m) == "string" and m or m.section
  results = tscan({
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

local query_module_rename = [[

]]

-- look at `lua/user/utils/ts.lua` for my old ts utils.
--
local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse()[1]
  return tree:root()
end

-- M.ntext = function(n,b) return tsq.get_node_text(n, b) end

--
-- MODULE ACTIONS
--

actions.m_edit = function(m)
  if m.type == "doom_module_single" then
    local buf = utils.get_buf_handle(m.path .. "init.lua")
    vim.api.nvim_win_set_buf(0, buf)
    -- vim.fn.cursor(er+1,ec)
  end
end

actions.m_rename = function(m)
  nui.nui_input("NEW NAME", function(value)
    if not check_if_module_name_exists(m, value) then
      log.debug("old name: ", m.name, ", new name:", value)

      -- note: if we know that the module is enabled/disabled then I shouldn't have to perform both check with ts

      local root_modules = utils.find_config("modules.lua")
      local buf = utils.get_buf_handle(root_modules)

      -- TODO: make sure this work -> get single mod string AND all comment
      local root_modules_query = string.format(
        [[
(return_statement
  (expression_list
    (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor
          (comment) @section_comment
          (field value: (string) @module_string)
            (#eq? @module_string "%s")
        ) @section_table
      )
    ) (#eq? @section_key "%s")
))]],
        m.name,
        m.section
      )

      print(root_modules_query)

      local root = get_root(buf)

      local parsed = vim.treesitter.parse_query("lua", root_modules_query)

      local mod_str_node
      local comment_nodes

      for id, node, _ in parsed:iter_captures(root, buf, root:start(), root:end_()) do
        local name = qp.captures[id]
        local node_text = ntext(node, buf)

        -- TODO: which captures is it that we want to look for?

        if name == string then
          -- collect the node
        elseif name == comment then
          -- collect all comment nodes
          --
        end

        -- if name == doom_capture_name then
        --   table.insert(t_matched_captures, node)
        -- end
      end

      if mod_str_node then
      end
      -- if a mod string is found then we can ignore analyzing comment nodes
      if
        comment_nodes --[[and m.disabled--]]
      then
      end

      -- MAKE SURE WE HAVE TO REQUIRED NODE (STRING|COMMENT) HERE
      --
      --  - create `local module_found = false`
      --          set it to module_found = { is_lua_string = true, ts_node = <the captured node>, ranges }
      --

      --  TODO: how did tj keep indentation here???

      --  - reverse update line

      --  - refactor everything into helpers.

      --  - redo treesitter transforms with `Architext` when I understand how everything is done
      --          with raw treesitter first.
      --

      -- OLD: watch some videos on treesitter to understand how this can be done more easilly
      -- for transforming a file

      --       local new_name = value
      --
      --       local buf, _ = transform_root_mod_file(m, function(buf, node, capt, node_text)
      --         local sr, sc, er, ec = node:range()
      --         if capt == "modules.enabled" then
      --           local offset = 1
      --           local exact_match = string.match(node_text, m.name)
      --           if exact_match then
      --             vim.api.nvim_buf_set_text(
      --               buf,
      --               sr,
      --               sc + offset,
      --               sr,
      --               sc + offset + string.len(m.name),
      --               { value }
      --             )
      --           end
      --         elseif capt == "modules.disabled" then
      --           local offset = 4
      --           local exact_match = string.match(node_text, m.name)
      --           if exact_match then
      --             vim.api.nvim_buf_set_text(
      --               buf,
      --               sr,
      --               sc + offset,
      --               sr,
      --               sc + offset + string.len(m.name),
      --               { value }
      --             )
      --           end
      --         end
      --       end)
      --
      --       write_to_root_modules_file(buf)
      --       shell_mod_rename_dir(m.section, m.path, new_name)
    end
  end)
end

-- todo: pass fuzzy, line
actions.m_create = function(sel, line)
  if string.len(line) < 2 then
    log.info("Module names require at least two characters!")
    return
  end

  log.debug("m_create()")

  local function create_module(new_name, for_section)
    -- need
    if not check_if_module_name_exists(for_section, new_name) then
      --   local buf, smll = transform_root_mod_file({ section = value.text })
      --   -- print("smll: ", smll)
      --   new_name = vim.trim(new_name, " ")
      --   vim.api.nvim_buf_set_lines(buf, smll, smll, true, { '"' .. new_name .. '",' })
      --   write_to_root_modules_file(buf)
      --   shell_mod_new(for_section, new_name)
    end
  end

  -- TODO: ACCOUNT FOR `ORIGIN` or always create under user and then move modules to core with `m_move`
  --
  -- alternatively ONLY show doom origin if `development` mode is set under settings?
  nui.nui_menu("CONFIRM CREATE", confirm_alternatives, function(value)
    if value.text == "yes" then
      nui.nui_menu("FOR SECTION:", conf_ui.settings.section_alternatives, function(value)
        create_module(line, value.text)
      end)
    end
  end)
end

--
-- - TODO: find name or comments in modules.lua and remove the line
-- - remove module that is disabled
--
actions.m_delete = function(m)
  nui.nui_menu("CONFIRM DELETE", confirm_alternatives, function(value)
    if value.text == "yes" then
      -- print("delete module: ", c.selected_module.section .. " > " .. c.selected_module.name)
      log.info("Deleting module: " .. m.origin .. " > " .. m.section .. " > " .. m.name)

      local root_modules = utils.find_config("modules.lua")
      local buf = utils.get_buf_handle(root_modules)

      -- TODO: make sure this work -> get single mod string AND all comment
      local delete_module_query = string.format(
        [[
(return_statement
  (expression_list
    (table_constructor
      (field
        name: (identifier) @section_key
        value: (table_constructor
          (comment) @section_comment
          (field value: (string) @module_string)
            (#eq? @module_string "%s")
        ) @section_table
      )
    ) (#eq? @section_key "%s")
))]],
        m.name,
        m.section
      )

      print(delete_module_query)
      local root = get_root(buf)
      local parsed = vim.treesitter.parse_query("lua", delete_module_query)

      -- TODO: finnish rename module first since this is the same code

      --       local buf, _ = transform_root_mod_file(m, function(buf, node, capt, node_text)
      --         local sr, sc, er, ec = node:range()
      --         if capt == "modules.enabled" then
      --           -- local offset = 1
      --           local exact_match = string.match(node_text, m.name)
      --           if exact_match then
      --             vim.api.nvim_buf_set_text(buf, sr, sc, er, ec + 1, { "" })
      --           end
      --         elseif capt == "modules.disabled" then
      --           -- local offset = 4
      --           local exact_match = string.match(node_text, m.name)
      --           if exact_match then
      --             vim.api.nvim_buf_set_text(buf, sr, sc, er, ec + 1, { "" })
      --           end
      --         end
      --       end)
      --
      --       write_to_root_modules_file(buf)
      --       shell_mod_remove_dir(m.path) -- shell: rm m.path
    end
  end)
end

-- use comment.nvim plugin or perform custom operation.
--
-- TODO: look into the source of comment.nvim and see how a comment is made and then just copy
-- the code to here. I think this is the best way of learning how to do this properly.
actions.m_toggle = function(m)

  local root_modules = utils.find_config("modules.lua")
  local buf = utils.get_buf_handle(root_modules)

  --   local buf, _ = transform_root_mod_file(m, function(buf, node, capt, node_text)
  --     local sr, sc, er, ec = node:range()
  --     if string.match(node_text, m.name) then
  --       if capt == "modules.enabled" then
  --         vim.api.nvim_buf_set_text(buf, sr, sc, er, ec, { "-- " .. node_text })
  --       elseif capt == "modules.disabled" then
  --         vim.api.nvim_buf_set_text(buf, sr, sc, er, ec, { node_text:sub(4) })
  --       end
  --     end
  --   end)
  --   write_to_root_modules_file(buf)
  log.info("Toggling module: " .. m.origin .. " > " .. m.section .. " > " .. m.name .. " = " .. tostring(not m.enabled))
end

-- this one requires that all of the above works since this is a compound of all of the above.
actions.m_move = function(m)
  --   -- move module into into (features/langs)
  --   -- 1. nui menu select ( other sections than self)
  --   -- 2. move module dir
  --   -- 3. transform `modules.lua` -> call `root_sync_modules` command??
end

-- this one is whacky but a fun experiment
actions.m_merge = function(m)
  -- select module A to merge into module B.
  log.debug("M MERGE")
end

actions.m_submit_module_to_upstream = function(m)
  --   TODO: EXPLICIT PROMPT ON WHAT IS GONNA HAPPEN HERE.

  -- create a PR onto `main` for selected module and submit PR.
  -- cherry pick relevant co mmits onto `main`
end

--
-- COMPONENT ACTIONS
--

-- NOTE: LESS FUNCS WITH VARIABLE ARGS.
--
-- okay so I am thinking that it would probably make sense to have fewer functions with
-- more finegrained args management so that we can just have a single bind per component?
-- i am not sure if this is the best idea yet but at least it is a nice learning
-- experiment.

-- SETTINGS
actions.c_edit_setting = function(buf, config)
  -- find settings prop in settings file
  -- enter insert at last position.
end
actions.c_add_new_setting = function(buf, config)
  -- find settings prop in settings file
  -- enter table snippet at last position in settings file.
end
actions.c_add_new_setting_to_mod = function(buf, config)
  -- same but for a single module.
end

-- ADD PACKAGES
actions.c_add_new_pkg_to_module = function(buf, config) end
actions.c_add_new_pkg_to_new_module = function(buf, config) end
actions.c_pkg_fork = function(buf, config) end
actions.c_pkg_clone = function(buf, config) end

-- ADD CONFIGS

-- ADD CMD
actions.c_cmd_add_new_to_sel_mod = function(buf, config) end
actions.c_cmd_add_to_new = function(buf, config) end
actions.c_cmd_add_to_existing = function(buf, config) end

-- ADD AUTOCMDS
actions.c_autocmd_add_to_exising = function(buf, config) end
actions.c_autocmd_add_to_new_mod = function(buf, config) end

-- BINDS
actions.c_edit_bind = function(buf, config)
  -- 1. find binds table.
  -- 2. find selected bind in table
  -- 3. find selected prop
  -- 4. put cursor in position.
  -- 5. enter insert mode.
end
actions.c_add_new_bind = function(buf, config)
  -- 1. check if module has binds table
  -- 2. check for regular binds AND leader table
  -- 3. enter new binds snippet before leader.
end
actions.c_add_new_leader = function(buf, config)
  -- 1. check if module has binds table
  -- 2. check for leader table
  -- 3. add to last
end
actions.c_add_to_selected_leader = function(buf, config)
  -- find selected leader bind in module file.
  -- enter new binds snippet in the correct selected leader node.
end
actions.c_edit_add_new_bind = function(buf, config) end
actions.c_add_new_bind_with_compose_ui = function(buf, config)
  -- use NUI to create a UI pipeline for creating a new bind
end

return actions
