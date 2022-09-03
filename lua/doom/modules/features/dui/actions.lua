local utils = require("doom.utils")
-- local fs = require("doom.utils.fs")
local system = require("doom.core.system")

-- local sh = require("user.modules.features.dui2.shell")
local nui = require("doom.modules.features.dui.nui")

-- wip: NEW `MODULES.LUA` QUERY. This one captures all relevant components.
-- (return_statement
--   (expression_list
--     (table_constructor
--       (field
--         name: (identifier) @section_key
--         value: (table_constructor
--           (comment) @section_comment ;; analyze if is -- "name", ...
--           (field value: (string) @section_string)
--         ) @section_table
--       )
--     ) ;;(#eq? @section_key "langs")
--   )
-- )

-- video:
--
-- tj embedded formatting:    https://www.youtube.com/watch?v=v3o9YaHBM4Q
-- tj execute anything:       https://www.youtube.com/watch?v=9gUatBHuXE0
--
-- tj and vigoux:             https://www.youtube.com/watch?v=SMt-L2xf-10

--  - TODO: rename module
--
--
--  - open new module in split
--  - edit module in split.
--
--  - settings
--
--  - packages
--
--  - configs
--
--  - cmds
--
--  - autocmds
--
--  - binds
--
--
--

local actions = {}

local confirm_alternatives = { "yes", "no" }

local function check_if_module_name_exists(c, new_name)
  print(vim.inspect(c.selected_module))
  local already_exists = false
  for _, v in pairs(c.all_modules_data) do
    if v.section == c.selected_module.section and v.name == new_name then
      print("module already exists!!!")
      already_exists = true
    end
  end
  return already_exists
end

local query_module_rename = [[

]]

-- look at `lua/user/utils/ts.lua` for my old ts utils.
--
local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "lua", {})
  local tree = parser:parse() -- [1] ??/
    return tree:root()
end

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

--  - add module mappings to picker
--  - print passed data and verify I get correct data
--  - load `modules.lua` into buf
--  - make query based on selection
--    use string format to populate the query with correct match and identifiers
--  - print query to see how it looks
--  - iterate capture: `@module_string`
--      first check if the capture exists as a regular string.
--
--  - iterate capture: `@module_comment`
--      pass comment to function that checks if there is a `^beginning` match for the module.
--
--
--  - create `local module_found = false`
--    set it to module_found = { is_lua_string = true, ts_node = <the captured node>, ranges }
--
--  - keep indentation
--
--  - reverse update line
--
--  - refactor everything into helpers.
--
--  - redo treesitter transforms with `Architext` when I understand how everything is done
--      with raw treesitter first.
--

actions.m_rename = function(m)
  nui.nui_input("NEW NAME", function(value)
    if not check_if_module_name_exists(c, value) then
      print("old name: ", m.name, ", new name:", value)

      -- TODO: watch some videos on treesitter to understand how this can be done more easilly
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

actions.m_create = function(m)
  local new_name
  local for_section

  nui.nui_menu("CONFIRM CREATE", confirm_alternatives, function(value)
    if value.text == "yes" then
      new_name = c.new_module_name
      nui.nui_menu("FOR SECTION:", conf_ui.settings.section_alternatives, function(value)
        for_section = value.text
        print("create mod >> new name:", for_section .. " > " .. new_name)
        --         if not check_if_module_name_exists(c, { section = nil }, value) then
        --           local buf, smll = transform_root_mod_file({ section = value.text })
        --           -- print("smll: ", smll)
        --           new_name = vim.trim(new_name, " ")
        --           vim.api.nvim_buf_set_lines(buf, smll, smll, true, { '"' .. new_name .. '",' })
        --           write_to_root_modules_file(buf)
        --           shell_mod_new(for_section, new_name)
        -- end
      end)
    end
  end)
end

--
-- - TODO: find name or comments in modules.lua and remove the line
-- - remove module that is disabled
--
actions.m_delete = function(c)
  nui.nui_menu("CONFIRM DELETE", confirm_alternatives, function(value)
    if value.text == "yes" then
      print("delete module: ", c.selected_module.section .. " > " .. c.selected_module.name)
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
actions.m_toggle = function(c)
  print("toggle: ", c.selected_module.name)
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
end

-- this one requires that all of the above works since this is a compound of all of the above.
actions.m_move = function(buf, config)
  --   -- move module into into (features/langs)
  --   -- 1. nui menu select ( other sections than self)
  --   -- 2. move module dir
  --   -- 3. transform `modules.lua`
end

-- this one is whacky but a fun experiment
actions.m_merge = function(buf, config)
  -- select module A to merge into module B.
end

actions.m_submit_module_to_upstream = function(buf, config)
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
