-- telescope modules
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local system = require("doom.core.system")
local fs = require("doom.utils.fs")
local ts = vim.treesitter

local dui_utils = require("doom.modules.features.dui.utils")

-- TODO: default <entre> selection should go to file in same buffer.
-- TODO: vertical / horizontal split.

local du = require("doom.utils")

local __attrs = {
  "name", "mode" --, "description"
}

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

local function get_keybind_leaf_candidates(buf, keybind)
  -- TEST VERSION TWO
  -- Improved version
  --
  -- Programmatically find th exact bind table where a binding is
  -- defined.

  local parser = vim.treesitter.get_parser(buf, "lua", {})
  local tree = parser:parse()[1]
  local root = tree:root()

  local query__find_tbl_w_2_indices = string.format(
    [[ (table_constructor) @bind_table ]],
    keybind.keys,
    get_last_char(keybind.keys)
  )

  local qtw2i = vim.treesitter.query.parse("lua", query__find_tbl_w_2_indices)


  -- TODO: If branch, check parent name?
  print("#######################################################")
  print("Keys:", keybind.keys)
  -- iterate all table constructors
  local cnt = 0
  local t_captured_candidates = {}
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

        local child2_text = ts.get_node_text(child2, buf)
        local is_indexed = false

        print(ci_named, ts.get_node_text(child_node, buf), child2_type, child2_text)

        -- if child_node:named_child_count() == 1 then
        --   print("==1")
        -- end


        -- Handle named fields. These can occur as first field in a table and
        -- so possibly might be [ indexed < 2 ]
        if (named_child_count > 1) then
          local child2_second = child_node:named_child(1)

          if child2_type == "identifier" then
            print("attr:", ts.get_node_text(child2, buf))
            local nt = ts.get_node_text(child2, buf)

            -- TODO: loop attrs and ensure that all have a match. If has_single_match
            -- then abort.

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
          -- Here indicates that there that first indexed field did not match
          -- our target pattern, therefore this table is invalid.
          -- Continue.
        else
          is_indexed = true

          -- lhs
          if indexed == 0 then
            -- print("?")
            if child2_type == "dot_index_expression" then
              valid = true
              print(string.format("A (%s): dot index expression, ci_named = %s, %s", indexed, ci_named, child2_text))
            elseif child2_type == "string" then
              -- match against `string_content` literally.
              local ct = ts.get_node_text(child2:named_child(), buf)
              if ct == keybind.keys then
                valid = true
                print(string.format("A (%s): keybind.keys, ci_named = %s, %s", indexed, ci_named, child2_text))
              elseif ct == get_last_char(keybind.keys) then
                valid = true
                print(string.format("A (%s): keybind.keys (last char), ci_named = %s, %s", indexed, ci_named, child2_text))
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
            print(msg, child2_text, child_node:named_child_count())
            if valid then
              candidate.rhs = child_node
            end
          end

          -- name
          if indexed == 2 and child2_type == "string" then
            valid = true
            print("  C, NAME:", child2_text)
            candidate.name = child_node
          end

          -- description
          if indexed == 3 and child2_type == "string" then
            valid = true
            print("   D, DESCRIPTION:", child2_text)
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

  return t_captured_candidates
end

-- if vim.g.mapper_action_on_enter == "definition" and vim.g.mapper_modules_dir then
M.mapper = function(opts)
  opts = vim.tbl_extend("force", opts or {}, {
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

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

        local buf = dui_utils.get_buf_handle(module_path)

        local leaf_candidates = get_keybind_leaf_candidates(buf, keybind)

        -- -- move cursor
        -- if #q > 0 then
        --   print("range of bind table [1]:", vim.inspect(q[1].range)) -- , vim.inspect(leader)
        --   b.set_cursor_to_buf(buf, q[1].range)
        -- else
        --   print("no bind table found")
        -- end


        print("captured nodes #:", #leaf_candidates)

        print("=================================")

        -- print(vim.inspect(leaf_candidates))

        local count_mismatches = 0

        -- FIX: This check for attr matches should be done directly in the
        -- leaf candidate finder func.

        for i, v in ipairs(leaf_candidates) do
          local text = ts.get_node_text(v.table, buf)
          for index, value in ipairs(__attrs) do
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

        -- TODO: now if there are more than one candidate left,
        -- i need to check the parent to see which one the binding
        -- resides in.
        -- TODO: handle case of  "<C-" "p>" branch, ie. broken up control
        -- key branch. >>> how are these keymaps built up with the keybmap
        -- service? I have to create a setup that only runs the service on a
        -- specific module that i am working on.

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
