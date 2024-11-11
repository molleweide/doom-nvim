-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local system = require("doom.core.system")
local fs = require("doom.utils.fs")

-- TODO: default <entre> selection should go to file in same buffer.

-- TODO: vertical / horizontal split.

local du = require("doom.utils")

-- TODO: Compile all telescope related stuff into one single file.

-- telescope-mapper modules
local _finders = require("doom.modules.core.nest.mapper.finders")
local _previewers = require("doom.modules.core.nest.mapper.previewers")
local _utils = require("doom.modules.core.nest.mapper.utils")

local function getLastControlChar(keybinds)
  local lastControlChar = nil
  local pattern = "<C%-.>"
  local pattern2 = "<F%d>"
  local pattern3 = "<A%-.>"
  for match in string.gmatch(keybinds, pattern) do
    lastControlChar = match     -- Update lastControlChar to the current match
  end
  return lastControlChar
end

local function get_last_char(keys)
  local has_last_control_char = getLastControlChar(keys)
  if has_last_control_char then
    return has_last_control_char
  else
    return keys:sub(-1)
  end
end

-- TODO: move this to dui/queries?? require("doom.modules.features.dui.queries")
--
-- This query was made for / expects an entry from the nest/mapper telescope
-- module.
-- keybind = {
--   buffer_only = false,
--   category = "unknown",
--   cmd = "<Plug>luasnip-next-choice",
--   description = "Luasnip next choice s",
--   description_display = "Luasnip next choice s",
--   display = <function 1>,
--   id = "luasnip_next_choice_s_s",
--   index = 1,
--   keys = "<C-k>",
--   lines = { "Id:           luasnip_next_choice_s_s", "Category:     unknown", "Mode:         select", "Keys:         <C-k>", "Command:      <Plug>luasnip-next-choice", "Buffer only:  false", "Options:      {noremap = true, silent = true}", "Definition:   :", "", "Luasnip next choice s" },
--   mode = "s",
--   module_origin = "features.snippets.luasnip_engine",
--   options = {
--     noremap = true,
--     silent = true
--   },
--   ordinal = "Luasnip next choice sluasnip_next_choice_s_s<C-k>unknown",
--   unique_identifier = "luasnip_next_choice_s_s",
--   value = "Luasnip next choice s"
-- }

-- (table_constructor
--   . [
--       (field value: (string content: (string_content) @sequence ))
--       (field value: (string content: (string_content) @char ))
--       (field value: (dot_index_expression))] @lhs
--
--   . (field value:
--       [(identifier)
--       (string_content)
--       (function_definition)
--       (dot_index_expression)]) @rhs
--
--   ; DESCR (required)
--   ; The name can either be the third index or the name key.
--   ; make both optional so that either one of them
--   ; . ((field) @description (#eq? @description "%s"))?
--   . ( (field value: (string content: (string_content))) @description  )?
--   (field
--     name: (identifier) @id
--     value:
--       (string content:
--         (string_content) @description ))?
--
--   ; MODE (optional)
--   (field
--     name: (identifier) @ide
--     value: (string content: (string_content) @mode )
--   )?
--
-- )

--
-- NOTE: Use InspectTree `o` to run the query editor.
local function query__leaf(keybind)
  -- local keys = du.escape_str(keybind.keys)
  local keys = keybind.keys

  -- NOTE: The issue now is that sometimes the name / descr comes before
  -- index 2 and so this makes the ts matching fail. how should this be
  -- handled? always enforce that shit?

  local ret = string.format([[ (table_constructor
                . [
                    (field value: (string content: (string_content) @sequence (#eq? sequence "%s")))
                    (field value: (string content: (string_content) @char (#eq? @char "%s")))
                    (field value: (dot_index_expression))] @lhs
                . (field value:
                    [(identifier)
                    (string)
                    (function_definition)
                    (dot_index_expression)]) @rhs
                ; DESCR (required)
                ; The name can either be the third index or the name key.
                ; make both optional so that either one of them
                . ((field) @description (#eq? @description "%s"))?
                (field
                  name: (identifier) @id (#eq? @id "name")
                  value:
                    (string content:
                      (string_content) @description (#eq? @description "%s")))?
                ; MODE (optional)
                (field
                  name: (identifier) @ide (#eq? @ide "\"mode\"")
                  value: (string content: (string_content) @mode (#eq? @mode "%s"))
                )?
              ) @bind_table ]],
    keys,
    get_last_char(keys),
    -- du.escape_str(keybind.keys),
    keybind.description,
    keybind.description,
    keybind.mode
  )

  return ret
end

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

local function get_abs_path_from_module_origin(keybind)
  local parts = vim.split(keybind.module_origin, "%.")
  local module_init_file = table.concat(parts, "/") .. "/init.lua"
  local module_path = system.doom_configs_root .. "/lua/doom/modules/" .. module_init_file
  local status
  if fs.file_exists(module_path) then
    status = "doom"
  else
    module_path = system.doom_configs_root .. "/lua/user/modules/" .. module_init_file
    if fs.file_exists(module_path) then
      status = "user"
    end
  end
  print("[NEST PICKERS:]", status, module_path)
  return module_path
end

-- if vim.g.mapper_action_on_enter == "definition" and vim.g.mapper_modules_dir then
M.mapper = function(opts)
  opts = vim.tbl_extend("force", opts or {}, {
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- SELECT DEFAULT | <ENTER>
      actions.select_default:replace(function()
        local keybind = action_state.get_selected_entry()

        -- print("keybind = ", vim.inspect(keybind))

        local module_path = get_abs_path_from_module_origin(keybind)

        actions.close(prompt_bufnr)

        if not module_path then
          log.info("nest telescope -> did not return a proper module_path")
          return
        end

        -- open file in split
        vim.cmd("set splitright")
        vim.cmd(string.format("vsplit %s", module_path))
        vim.cmd("set splitright!")
        vim.cmd("stopinsert")

        local ts = require("doom.modules.features.dui.ts")
        local b = require("doom.modules.features.dui.buf")

        local query = query__leaf(keybind)

        print(query)

        local q, buf = ts.get_captures(module_path, query, "lhs")

        if #q > 0 then
          print("range of bind table [1]:", vim.inspect(q[1].range))           -- , vim.inspect(leader)
          b.set_cursor_to_buf(buf, q[1].range)
        else
          print("no bind table found")
        end
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
