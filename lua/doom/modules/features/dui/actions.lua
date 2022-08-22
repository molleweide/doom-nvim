local utils = require("doom.utils")
-- local fs = require("doom.utils.fs")
local system = require("doom.core.system")

-- local sh = require("user.modules.features.dui2.shell")
local nui = require("doom.modules.features.dui.nui")

-- TODO: MODULES CRUD
--
--  - play around with nui.
--
--  - RENAME module
--
--  - DELETE module
--
--  - CREATE module
--
--
--
--
--  - open new module in split
--  - edit module in split.
--
--  TODO: COMPONENTS CRUD
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

-- requires
--    - replace internal require statements
--    - rename module dir
--    - rename module in ./modules.lua
actions.m_rename = function(m)
  nui.nui_input("NEW NAME", function(value)
    if not check_if_module_name_exists(c, value) then
      print("old name: ", m.name, ", new name:", value)
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

-- TODO: what happens if you try to remove a module that has been disabled ?? account for disabled in modules.lua
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

actions.m_move = function(buf, config)
  --   -- move module into into (features/langs)
  --   -- 1. nui menu select ( other sections than self)
  --   -- 2. move module dir
  --   -- 3. transform `modules.lua`
end

actions.m_merge = function(buf, config)
  --   -- 1. new prompt for B
  --   -- 2. select which module to pull into A
  --   -- 3. do...
end

actions.m_submit_module_to_upstream = function(buf, config)
  -- create a PR onto `main` for selected module and submit PR.
  -- cherry pick relevant co mmits onto `main`
end

--
-- COMPONENT ACTIONS
--

actions.c_edit_setting = function(buf, config) end
actions.c_edit_bind = function(buf, config) end
actions.c_add_new_bind = function(buf, config) end
actions.c_edit_add_new_bind = function(buf, config) end
actions.c_add_new_bind_with_compose_ui = function(buf, config)
  -- use NUI to create a UI pipeline for creating a new bind
end

return actions
