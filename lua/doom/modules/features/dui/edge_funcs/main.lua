local M = {}

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- FLATTENER -> MAIN MENU

--- This could probably go into a `results_static.lua`
--- so that these kinds of menus are not mixed with dynamically
--- generated results/entries
---@return list of main menu items
M.main_menu_flattened = function()
  local doom_menu_items = {
    {
      list_display_props = {
        { "open user config" },
      },
      mappings = {
        ["<CR>"] = function()
          vim.cmd(("e %s"):format(require("doom.core.config").source))
        end,
      },
      ordinal = "userconfig",
    },
    {
      list_display_props = {
        { "browse user settings" },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line, cb)
          DOOM_UI_STATE.query = {
            type = "settings",
          }
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "usersettings",
    },
    {
      list_display_props = {
        { "browse all modules" },
      },
      mappings = {
        ["<CR>"] = function(fuzzy, line)
          DOOM_UI_STATE.query = {
            type = "modules",
            -- origins = {},
            -- categories = {},
          }
          DOOM_UI_STATE.next()
        end,
      },
      ordinal = "modules",
    },
    {
      list_display_props = {
        { "browse all binds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "binds",
    },
    {
      list_display_props = {
        { "browse all autocmds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "autocmds",
    },
    {
      list_display_props = {
        { "browse all cmds" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "cmds",
    },
    {
      list_display_props = {
        { "browse all packages" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
      ordinal = "packages",
    },
    {
      list_display_props = {
        { "browse all jobs" },
      },
      mappings = {
        ["<CR>"] = function() end,
      },
    },
  }

  for k, v in pairs(doom_menu_items) do
    table.insert(v.list_display_props, 1, { "MAIN" })
    v["type"] = "doom_main_menu"
    -- i(v)
  end

  -- i(doom_menu_items)

  return doom_menu_items
end

return M
