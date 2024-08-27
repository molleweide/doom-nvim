-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- TODO: Compile all telescope related stuff into one single file.

-- telescope-mapper modules
local _finders = require("doom.modules.core.nest.mapper.finders")
local _previewers = require("doom.modules.core.nest.mapper.previewers")
local _utils = require("doom.modules.core.nest.mapper.utils")

local M = {}

-- -- If the enter key ('<CR>') should execute the selected
-- -- keybind then set a custom mapping
-- if vim.g.mapper_action_on_enter == "execute" then
--   opts = vim.tbl_extend("force", opts or {}, {
--     attach_mappings = function(prompt_bufnr)
--       local actions = require("telescope.actions")
--       local action_state = require("telescope.actions.state")
--       actions.select_default:replace(function()
--         local keybind = action_state.get_selected_entry()
--         -- Replace codes (e.g. '<CR>') with their internal representation
--         local cmd_k = vim.api.nvim_replace_termcodes(keybind.keys, true, false, true)
--         -- Send the keybinding to Neovim
--         vim.api.nvim_feedkeys(cmd_k, "t", true)
--         return actions.close(prompt_bufnr)
--       end)
--       return true
--     end,
--   })
-- end

        -- FIX: support DOOM vs USER modules..
M.mapper = function(opts)
  -- if vim.g.mapper_action_on_enter == "definition" and vim.g.mapper_modules_dir then
  opts = vim.tbl_extend("force", opts or {}, {
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      actions.select_default:replace(function()
        local keybind = action_state.get_selected_entry()


        local parts = vim.split(keybind.module_origin, "%.")
        local module_init_file = require("doom.core.system").doom_modules_path()
            .. "/"
            .. table.concat(parts, "/")
            .. "/init.lua"

        vim.cmd("set splitright")
        vim.cmd(string.format("vsplit %s", module_init_file))
        vim.cmd("set splitright!")
        vim.cmd("stopinsert")
        return actions.close(prompt_bufnr)
      end)

      return true
    end,
  })
  -- end

  pickers
      .new(opts or {}, {
        prompt_title = "Select a mapping",
        results_title = "Mappings",
        finder = _finders.mapper_finder(_utils.get_mappers()),
        sorter = conf.generic_sorter(opts),
        previewer = _previewers.previewer.new(opts),
      })
      :find()
end

return M
