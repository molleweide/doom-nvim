-- NOTE: The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.
local actions = require("telescope.actions")

local mappings = {

  -- ENTRY ITEM: MODULE
  --
  -- When an entry represents a full module, then these binds will apply
  -- to that entry.
  modules = {
    -- EDIT
    ["<CR>"] = function(prompt_bufnr, entry, key)
      -- DOOM_UI_STATE.selected_module = fuzzy.value
      -- ax.m_edit(fuzzy.value)
      P(entry.value)
      -- print(("Hi from mappigs: %s"):format(key))
      -- print(entry.value.path_init)
      actions.close(prompt_bufnr)
      vim.cmd(string.format("edit %s", entry.value.path_init))
    end,
    -- INSPECT MODULE
    ["<C-a>"] = function(fuzzy, line, key)
      print(("Hi from mappigs: %s"):format(key))
      -- DOOM_UI_STATE.query = {
      --     type = "SHOW_SINGLE_MODULE",
      --     -- components = {}
      -- }
      -- DOOM_UI_STATE.selected_module = fuzzy.value
      -- DOOM_UI_STATE.next()
    end,

    ["<C-b>"] = function(fuzzy, _)
      -- DOOM_UI_STATE.query = {
      --   type = "MODULE_COMPONENT",
      --   -- components = {}
      -- }
      -- DOOM_UI_STATE.selected_component = fuzzy.value
      -- DOOM_UI_STATE.next()
    end,
    ["<C-e>"] = function(sel, line)
      -- ax.m_create(sel, line)
    end,
    ["<C-r>"] = function(fuzzy, _)     -- note: atm it seems that ^r closes the window or does something wierd. registers?!
      -- ax.m_rename(fuzzy.value)
    end,
    ["<C-x>"] = function(fuzzy, _)
      -- ax.m_delete(fuzzy.value)
    end,
    ["<C-t>"] = function(prompt_bufnr, entry, key)     -- TOGGLE MODULE(S)
      print(
        ("entry.value.enabled: %s -> %s"):format(
          entry.value.enabled,
          not entry.value.enabled
        )
      )
      entry.value.enabled = not entry.value.enabled

      -- local state = require("telescope.actions.state")
      -- local line = state.get_current_line(prompt_bufnr)
      local action_state = require("telescope.actions.state")

      action_state.get_current_picker(prompt_bufnr):refresh()

      print("post refresh")

      local Path = require("pathlib")
      print("PATH:", Path(entry.value.path))

      require("doom.modules.features.dui.modules_manager").manage_modules_tree({
        target_module_name = entry.value.name,
        target_module_dir = Path(entry.value.path),
        action = "TOGGLE",
      })
    end,
    ["<C-y>"] = function(fuzzy, _)
      -- ax.m_move(fuzzy.value)
    end,
    ["<C-h>"] = function(fuzzy, _)
      -- ax.m_merge()
    end,
    ["<C-q>"] = function(fuzzy, _)
      -- ax.m_submit_module_to_upstream()
    end,
  },
}

return mappings
