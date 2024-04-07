local dorothy = {}
--------------------------------------------

-- TODO:
--  - if ! --shell flag then prompt with a selection
--    menu for possible shells, eg. bash or nvim
--

--------------------------------------------

-- local Input = require("nui.input")
-- local event = require("nui.utils.autocmd").event
--
-- local popup_options = {
--   relative = "cursor",
--   position = {
--     row = 1,
--     col = 0,
--   },
--   size = 20,
--   border = {
--     style = "rounded",
--     text = {
--       top = "[Input]",
--       top_align = "left",
--     },
--   },
--   win_options = {
--     winhighlight = "Normal:Normal",
--   },
-- }
--
-- local dorothy_add_file_input = Input(popup_options, {
--   prompt = "> ",
--   default_value = "42",
--   on_close = function()
--     print("Input closed!")
--   end,
--   on_submit = function(value)
--     print("Value submitted: ", value)
--   end,
--   on_change = function(value)
--     print("Value changed: ", value)
--   end,
-- })
--
-- dorothy_add_file_input:on(event.BufLeave, function()
--   dorothy_add_file_input:unmount()
-- end)

-- local function dorothy_add_file_input_mounter(options, new_name)
--   local command = "dorothy-add-file"
--   -- mount/open the component
--   input:mount()
--   local handle = io.popen(command)
--   local result = handle:read("*a")
--   handle:close()
--   -- Print the captured stdout
--   print("Captured output:")
--   print(result)
-- end

---------
-- autoformat dorothy on save.
dorothy.autocommands = {
  -- {
  --   "ColorScheme",
  --   "*",
  --   function()
  --     print("colorscheme update")
  --     print(vim.inspect(require('heirline').statusline))
  --     -- doom.modules.features.statusline2.configs["heirline.nvim"]()
  --   end,
  -- },
  -- {
  -- user
  --  - auto commit on change?
  --  -> qhq / tmux / other??
  -- }
}

-- TODO:
--  1. create new command in split to the right
--  2. hidden command
--  3. add new command to core
--    run dorothy add file command and get file path returned.

dorothy.binds = {
  "<leader>",
  name = "+prefix",
  {
    "<leader>",
    name = "+prefix",
    {
      "d",
      name = "+dorothy",
      {
        "a",
        name = "+add_file",
        {
          {
            "u",
            name = "add command",
            function()
              -- TODO: pass args to input here
              -- flags/help/test
              print("doro add file -> u")
            end,
          }, -- user command
          -- { "m" }, -- user command minimal
          -- { "d" }, -- user command.local
          -- { "h" }, -- user config
          -- { "h" }, -- user config.local
          -- { "h" }, -- user source
          -- -- { "h" }, -- user source.local ???
          -- { "h" }, -- core command
          -- { "h" }, -- core source
          -- { "h" }, -- core config
        },
      },
    },
  },
}

return dorothy
