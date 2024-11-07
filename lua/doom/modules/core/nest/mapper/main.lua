-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local du = require("doom.utils")

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

      local system = require("doom.core.system")
      local fs = require("doom.utils.fs")

      -- SELECT DEFAULT | <ENTER>
      actions.select_default:replace(function()
        local keybind = action_state.get_selected_entry()

        -- get doom / user path
        local parts = vim.split(keybind.module_origin, "%.")
        local module_init_file = table.concat(parts, "/") .. "/init.lua"
        local module_path = system.doom_configs_root
            .. "/lua/doom/modules/"
            .. module_init_file
        local status
        if fs.file_exists(module_path) then
          status = "doom"
        else
          module_path = system.doom_configs_root
              .. "/lua/user/modules/"
              .. module_init_file
          if fs.file_exists(module_path) then
            status = "user"
          end
        end

        print(status, module_path)
        actions.close(prompt_bufnr)

        vim.cmd("set splitright")
        vim.cmd(string.format("vsplit %s", module_path))
        vim.cmd("set splitright!")
        vim.cmd("stopinsert")

        -- NOW WE ARE IN THE BINDIGS FILE

        local ts = require("doom.modules.features.dui.ts")
        local dq = require("doom.modules.features.dui.queries")

        -- test_query = [[
        --   (field
        --   ) @leader_field
        -- ]]

        local test_query = [[
          (table_constructor
                . (field value: (string) @ld (#eq? @ld "\"<leader>\""))
            ) @leader_table
        ]]

        local leader, buf = ts.get_captures(module_path, test_query, "leader_table")
        if #leader > 0 then
          print("has leaders !!!") -- , vim.inspect(leader)
        else
          print("no leader :(")
        end

        -- find bindings lhs_str table
        print("keybind = ", vim.inspect(keybind))

        -- TODO: find
        --  1. check if lhs matches the char
        --  >>> this can fail if the code is a table idenfier
        -- 2. check if the description matches?
        -- >>> iirc name desc is required
        -- 3. if has mode attr then also check for the mode.
        -- >>> this is important because some keys have the same
        -- 4.

        local function get_bind_table__from_lhs_string(lhs_str)
          -- lhs_str = du.escape_str(lhs_str)
          print("from lhs string >>>", vim.inspect(lhs_str))
          return string.format(
            [[
              (table_constructor
              . (field value:
                  (string content:
                    (string_content) @lhs (#lua-match? @lhs "%s")
                  )
                )
              ) @bind_table
            ]],
            lhs_str
          -- lhs_str.rhs,
          -- lhs_str.name
          )
        end

        local bind_table, buf = ts.get_captures(
          module_path,
          get_bind_table__from_lhs_string(keybind.keys),
          "bind_table"
        )

        if #bind_table == 0 then
          local function get_bind_table__by_name_attr(name_attr)
            name_attr = du.escape_str(name_attr)
            print("by name attr >>>", vim.inspect(name_attr))
            return string.format(
              [[
              (table_constructor
                (field
                  name: (identifier)
                  value:
                    (string content:
                      (string_content) @descr (#eq? @descr "%s")
                    )
                  )
              ) @bind_table
            ]],
              name_attr
            )
          end
          bind_table, buf = ts.get_captures(
            module_path,
            get_bind_table__by_name_attr(keybind.description),
            "bind_table"
          )
        end

        -- keybind =  {
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

        print("?????/")

        -- test final query
        -- local name_attr = du.escape_str(name_attr)
        --

        local function getLastControlChar(keybinds)
          local lastControlChar = nil

          -- TODO: also check for fnum keys as well. And also <A-.>

          -- Pattern to match <C-.> where '.' can be any character
          local pattern = "<C%-.>"

          for match in string.gmatch(keybinds, pattern) do
            lastControlChar = match -- Update lastControlChar to the current match
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


        if keybind.keys:match("<C-.>") then
          -- this means that the lhs contains a control char.
          -- This means that we want to get the first control char from the end.
        end

        -- FIX: if the lhs is a control char, then i have to make sure that
        -- it is handled properly.

        -- print("by name attr >>>", vim.inspect(name_attr))
        local bind_query = string.format(
          [[
              (table_constructor
                . [
                    (field value: (string content: (string_content) sequence (#eq? sequence "%s")))
                    (field value: (string content: (string_content) @char (#eq? @char "%s")))
                    (field value: (dot_index_expression))] @lhs

                . (field value:
                    [(identifier)
                    (string_content)
                    (function_definition)
                    (dot_index_expression)]) @rhs

                ; DESCR (required)
                (field
                  name: (identifier) @id (#eq? @id "name")
                  value:
                    (string content:
                      (string_content) @description (#eq? @description "%s")))

                ; MODE (optional)
                (field
                  name: (identifier) @ide (#eq? @ide "\"mode\"")
                  value: (string content: (string_content) @mode (#eq? @mode "%s"))
                )?

              ) @bind_table
            ]],
          keybind.keys,
          get_last_char(keybind.keys),
          -- du.escape_str(keybind.keys),
          keybind.description,
          keybind.mode
        )

        bind_table, buf = ts.get_captures(
          module_path,
          bind_query,
          "lhs"
        )

        print("final:", vim.inspect(bind_table))

        local b = require("doom.modules.features.dui.buf")

        if #bind_table > 0 then
          print("range of bind table [1]:", vim.inspect(bind_table[1].range)) -- , vim.inspect(leader)
          b.set_cursor_to_buf(buf, bind_table[1].range)
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
