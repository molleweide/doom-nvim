local utils = require("doom.utils")
local mod = require("doom.modules.utils")
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

      local ret = mod.root_modules_rename(m.section, m.name, value)

      if not ret then
        log.info("Renaming was unsuccessful - perhaps no captures were found in `modules.lua`.")
      else

        -- RENAME DIR
        --
        -- shell_mod_rename_dir(m.section, m.path, new_name)

        -- write modules.lua here? with vim or libuv??

        -- advanced: rename module internal require statements?
      end

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
    local ret = mod.root_modules_new(for_section, new_name)
    if not ret then
      log.info("Adding new module to `modules.lua` was unsuccessful.")
    else
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
      log.info("Trying to DELETE module: " .. m.origin .. " > " .. m.section .. " > " .. m.name)

      local ret = mod.root_modules_delete(m.section, m.name)
      if not ret then
        log.info("Deletion was unsuccessful.")
      else
      end

      -- write_to_root_modules_file(buf)
      -- shell_mod_remove_dir(m.path) -- shell: rm m.path
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

  log.info(
    "Toggling module: "
      .. m.origin
      .. " > "
      .. m.section
      .. " > "
      .. m.name
      .. " = "
      .. tostring(m.enabled)
  )
  local ret = mod.root_modules_toggle(m.section, m.name)
  if not ret then
    log.info("Toggling module was unsuccessful.")
  else
  end
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

-- TODO: rename each func to `manage_ <component>(opts)`
--  so that I can use the same func every where but only change the
--  args when necessary.

-- NOTE: how do I distinguish between DOOM and MOD here

-- SETTINGS
actions.c_edit_setting = function(sel, line)
  log.info("Edit single doom setting.")
  print(vim.inspect(sel))
  -- find settings prop in settings file
  -- enter insert at last position.

  -- if no module is selected then do root settings
end
actions.c_add_new_setting = function(buf, config)
  log.info("Add new doom setting.")
  -- find settings prop in settings file
  -- enter table snippet at last position in settings file.
end
actions.c_add_new_setting_to_mod = function(buf, config)
  -- same but for a single module.
  -- if mod selected > then do...
end

-- ADD PACKAGES
actions.c_add_new_pkg_to_module = function() end
actions.c_add_config_to_pkg = function() end
actions.c_add_new_pkg_to_new_module = function() end
actions.c_pkg_fork = function() end
actions.c_pkg_clone = function() end
actions.c_remove_pkg = function() end

-- ADD CONFIGS
actions.c_remove_sel_config = function() end

-- ADD CMD
actions.c_cmd_add_new_to_sel_mod = function(buf, config)
  -- requires module to have been selected.
end
actions.c_cmd_add_to_new_create_new_mod = function(buf, config) end
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

--
-- USER CONFIG
--

-- todo: play around with functions for inserting templates and shit into
-- `./config.lua` which is a big playground.
--
-- config test add setting
-- config test add function ..

return actions
