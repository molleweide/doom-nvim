-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local system = require("doom.core.system")
local fs = require("doom.utils.fs")

local dui_utils = require("doom.modules.features.dui.utils")

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

  -- NOTE: currently, in mapper the keybdings name prop is assigned to the description
  -- prop in mapper, ie. name = description AND the real bindings description
  -- prop is not used. <<< FIX: this !!
  --
  -- TODO: should i dynamically build the query?
  --
  --
  -- TODO: get tables that have at least two string fields 1 and 2.

  -- NOTE: The goal is to have something that is ruthlessly stable so that we
  -- can truly get back to whatever bindings that we ever define so that the
  -- user can change them from whereever when ever.
  -- TODO: 1. Capture all table constructors that have at least indexed fields.
  -- then check for the first and second match. if match then check further.
  -- narrow down and then fucking get the shit going.
  -- 2. Is there a third and fourth indexed field? -> match with name/description.
  -- 3. otherwise, check for the named keys [name | buffer | mode | options]
  --
  -- TEST:
  -- 1. First get tables that have two indexed fields where the first one is
  -- string = LHS, and second is <any> type indexed.
  -- 2. Then check if there is a third indexed, or fourth?
  -- 3. now start looking for all the named keys.

  local ret = string.format(
    [[ (table_constructor
                . [
                    (field value: (string content: (string_content) @sequence (#eq? sequence "%s")))
                    (field value: (string content: (string_content) @char (#eq? @char "%s")))
                    (field value: (dot_index_expression))] @lhs

                . (field value:
                    [(identifier)
                    (string)
                    (function_definition)
                    (dot_index_expression)]) @rhs

                ; NAME
                . ((field) @name (#eq? @name "%s"))?
                (field
                  name: (identifier) @id (#eq? @id "name")
                  value:
                    (string content:
                      (string_content) @name (#eq? @name "%s")))?

                ; MODE (optional)
                (field
                  name: (identifier) @ide (#eq? @ide "\"mode\"")
                  value: (string content: (string_content) @mode (#eq? @mode "%s"))
                )?

                ; OPTIONS
                ; check for the optios table.
              ) @bind_table ]],
    keys,
    get_last_char(keys),
    keybind.description,
    keybind.description,
    keybind.mode
  )

  ret = string.format(
    [[ (table_constructor
                . [
                    (field value: (string content: (string_content) @sequence (#eq? sequence "%s")))
                    (field value: (string content: (string_content) @char (#eq? @char "%s")))
                    (field value: (dot_index_expression))] @lhs

                . (field value:
                    [(identifier)
                    (string)
                    (function_definition)
                    (dot_index_expression)]) @rhs


                ; name

                ; description


              ) @bind_table ]],
    keys,
    get_last_char(keys)
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

        print("keybind = ", vim.inspect(keybind))

        local module_path = get_abs_path_from_module_origin(keybind)

        actions.close(prompt_bufnr)

        if not module_path then
          log.info("nest telescope -> did not return a proper module_path")
          return
        end

        -- open file in split
        -- vim.cmd("set splitright")
        -- vim.cmd(string.format("vsplit %s", module_path))
        -- vim.cmd("set splitright!")
        vim.cmd(string.format("e %s", module_path))
        vim.cmd("stopinsert")

        local ts = require("doom.modules.features.dui.ts")
        local b = require("doom.modules.features.dui.buf")

        local query = query__leaf(keybind)

        print(query)

        local q, buf = ts.get_captures(module_path, query, "lhs")

        if #q > 0 then
          print("range of bind table [1]:", vim.inspect(q[1].range)) -- , vim.inspect(leader)
          b.set_cursor_to_buf(buf, q[1].range)
        else
          print("no bind table found")
        end

        -- TEST VERSION TWO
        -- Improved version
        --
        -- Programmatically find th exact bind table where a binding is
        -- defined.

        local buf = dui_utils.get_buf_handle(module_path)
        local parser = vim.treesitter.get_parser(buf, "lua", {})
        local tree = parser:parse()[1]
        local root = tree:root()

        local query__find_tbl_w_2_indices = string.format(
          [[ (table_constructor) @bind_table ]],
          keybind.keys,
          get_last_char(keybind.keys)
        )

        local qtw2i = vim.treesitter.query.parse("lua", query__find_tbl_w_2_indices)

        local ts = vim.treesitter

        print("#######################################################")

        print("Keys:", keybind.keys)

        -- TODO: If branch, check parent name?

        local cnt = 0

        local t_captured_candidates = {}

        -- iterate all table constructors
        for id, capture_node, _ in qtw2i:iter_captures(root, buf) do
          -- iter
          print("----------------------")
          local ci = 0
          local ci_named = 0
          local indexed = 0

          local indexed_nodes = {}

          local candidate = {
            table = capture_node,
            named_attrs = {}
          }



          local prev_chnamed_count
          local prev_was_indexed

          for child_node in capture_node:iter_children() do
            -- check for the first indexed occurence.
            if child_node:named() and child_node:type() == "field" then
              local valid = false

              local child2 = child_node:named_child()
              local child2_type = child_node:named_child():type()
              local named_child_count = child_node:named_child_count()

              local text = ts.get_node_text(child2, buf)

              -- print(ci_named, ts.get_node_text(child_node, buf), child2_type, text)

              -- if child_node:named_child_count() == 1 then
              --   print("==1")
              -- end

              local is_indexed = false

              -- enter an indexed field
              if (child_node:named_child_count() > 1) then
                local child2_second = child_node:named_child(1)

                if child2_type == "identifier" then
                  print("attr:", ts.get_node_text(child2, buf))
                  local nt = ts.get_node_text(child2, buf)

                  if child2_second:type() == "string" then
                    local nt2 = ts.get_node_text(child2_second:named_child(), buf)
                    if nt == "name" then
                      local compare = nt2 == keybind.description
                      print("::::", nt2, keybind.description, compare)
                      candidate.named_attrs.name = child2
                      candidate.named_attrs.name_match = compare
                      print(">", nt2, keybind.description)
                    elseif nt == "mode" then
                      candidate.named_attrs.mode = child2
                      candidate.named_attrs.mode_match = nt2 == keybind.mode
                    end
                  else
                    if nt == "buffer" then
                      candidate.named_attrs.buffer = child2
                    elseif nt == "options" then
                      candidate.named_attrs.options = child2
                    end
                  end
                end
              elseif prev_was_indexed and indexed == 0 then
                -- we dont want to
              else
                is_indexed = true

                -- lhs
                if indexed == 0 then
                  -- print("?")
                  if child2_type == "dot_index_expression" then
                    valid = true
                    print(string.format("A (%s): dot index expression, ci_named = %s, %s", indexed, ci_named, text))
                  elseif child2_type == "string" then
                    -- match against `string_content` literally.
                    local ct = ts.get_node_text(child2:named_child(), buf)
                    if ct == keybind.keys then
                      valid = true
                      print(string.format("A (%s): keybind.keys, ci_named = %s, %s", indexed, ci_named, text))
                    elseif ct == get_last_char(keybind.keys) then
                      valid = true
                      print(string.format("A (%s): keybind.keys (last char), ci_named = %s, %s", indexed, ci_named, text))
                    end
                  end

                  if valid then
                    candidate.lhs = child_node
                  end
                end

                -- RHS
                -- we have found LHS candidate already. now we want to check that
                -- the field only has one child count which indicates it is a RHS,
                -- and not a named attr.
                if indexed == 1 then
                  local msg = ""
                  if child2_type == "identifier" then
                    valid = true
                    msg = " B: identifier:"
                  elseif child2_type == "string" then
                    valid = true
                    msg = " B: string:"
                  elseif child2_type == "function_definition" then
                    valid = true
                    msg = " B: function_definition:"
                  elseif child2_type == "dot_index_expression" then
                    valid = true
                    msg = " B: dot_index_expression:"
                  end
                  print(msg, text, child_node:named_child_count())
                  if valid then
                    candidate.rhs = child_node
                  end
                end

                -- name
                if indexed == 2 and child2_type == "string" then
                  valid = true
                  print("  C, NAME:", text)
                  candidate.name = child_node
                end

                -- description
                if indexed == 3 and child2_type == "string" then
                  valid = true
                  print("   D, DESCRIPTION:", text)
                  candidate.description = child_node
                end

                if valid then
                  table.insert(indexed_nodes, child_node)
                  indexed = indexed + 1
                end
              end

              prev_was_indexed = is_indexed
              ci_named = ci_named + 1
            end

            ci = ci + 1
          end

          if indexed >= 2 then
            -- table.insert(t_captured_candidates, { node = capture_node, indexed = indexed })
            candidate.indexed = indexed
            table.insert(t_captured_candidates, candidate)
            print(vim.inspect(candidate))
          end

          if indexed > 1 then
            print(
              "indexed > 1 | Captured table >>>",
              ts.get_node_text(capture_node, buf)
            )
          end

          -- print("children #:", ci, ci_named)

          cnt = cnt + 1
        end

        print("captured nodes #:", #t_captured_candidates)

        print("=================================")

        local attrs = {
          "name", "description", "mode"
        }

        -- print(vim.inspect(t_captured_candidates))

        local count_mismatches =0


        -- TODO: now if there are more than one candidate left,
        -- i need to check the parent to see which one the binding
        -- resides in.

        for i, v in ipairs(t_captured_candidates) do
          local text = ts.get_node_text(v.table, buf)
          for index, value in ipairs(attrs) do
            print(v.named_attrs[value .. "_match"])
            if v.named_attrs[value .. "_match"] == false then
              count_mismatches = count_mismatches + 1
            end
          end
          if count_mismatches == 0 then
            print(v.indexed, text)
            -- print(vim.inspect(v))
          end
        end

        print("=================================")

        -- print("COUNT TABLES = ", cnt)
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
