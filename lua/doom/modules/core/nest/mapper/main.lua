-- telescope modules
local log = require("doom.utils.logging")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local system = require("doom.core.system")
local utils = require("doom.utils")
local fs = require("doom.utils.fs")
local ts = vim.treesitter

local b = require("doom.modules.features.dui.buf")

-- HACK: If there is ambiguities, when i could just create a new
-- telescope step for the leaf candidates and by so let the
-- user decide which one to go to.

local dui_utils = require("doom.modules.features.dui.utils")

-- TODO: default <entre> selection should go to file in same buffer.
-- TODO: vertical / horizontal split.
-- TODO: add new binding to same table if possible.
-- TODO: add new leader.
-- TODO: If one of the indexed fields is an identifier, then use LSP to
--          obtain the real value and see if I can sus out more specific info.
-- TODO: if you dont specify a module to add bind/feature to, then, add
--          the binding to root config.lua
--
-- TODO: add bind / add sibling to bind leaf.
-- TODO: add bind -> type in the char pattern that we want to use for bind.
--            find modules that have existing binds that match this new
--            pattern, and ask, do you want to add this bind to an existing
--            module with similar binds/leaders?
--
-- TODO: Add binds for editing every component of a binding.
--        Again, use vim ui lib to get user input in a nice way and ensure
--        that user enters a new valid good value.
--

-- TODO: doom module buffer bindigs.
-- ~ [b ]b buffer mappings, (jump to next/prev binding), that only are
-- ~ [c ]c jump to next/prev doom component.
-- ~ [p ]p jump to next/prev package.
-- added upon entering a doom module.
-- !!!

-- HACK: try out the `swap_nodes` function.

local function has_grand_parent() end

local function has_grand_parent_of_type() end

local function has_parent_of_type() end

local function has_child_of_type() end

-- eg <name> = ....
local function has_field_identifier() end

local function has_n_named_children() end

local function has_indexed_fields() end

local function has_n_indexed_fields() end

local __attrs = {
  "name",
  "mode",   --, "description"
}

-- telescope-mapper modules
local _finders = require("doom.modules.core.nest.mapper.finders")
local _previewers = require("doom.modules.core.nest.mapper.previewers")
local _utils = require("doom.modules.core.nest.mapper.utils")

local function util_ensure_no_linesplits(data)
  if type(data) == "string" then
    data = vim.split(data, "\n")
    -- data = { data }
  end
  return data
end

local function parse_key_sequence(keys)
  local ret = {}
  local patterns = {
    { "<leader>", 8 },
    { "<C%-.>",   5 },
    { "<A%-.>",   5 },
    { "<F%d>",    4 },
    { "%a",       1 },
    { "%p",       1 },
    -- "<A%-.>",
  }
  local i = 1
  while i < keys:len() + 1 do
    local pi = 1
    local pat
    local has_match = false
    while not has_match or not (pi <= #patterns) do
      pat = patterns[pi]
      local ok, substr = pcall(string.sub, keys, i, i + pat[2] - 1)
      if ok then
        if substr:match(pat[1]) then
          -- print("MATCH = ", check_this)
          has_match = true
          table.insert(ret, substr)
          i = i + pat[2]
        end
        print(substr, pat[1], has_match)
      end
      pi = pi + 1
    end
    if not has_match then
      return "no match"
    end
  end

  return ret
end

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
  -- print("[NEST PICKERS:]", status, module_path)
  return module_path
end

-- Get TSNodes for table constructors that match the
-- pattern for declaring doom keybind leaves.
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
      named_attrs = {},
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
        if named_child_count > 1 then
          local child2_second = child_node:named_child(1)

          if child2_type == "identifier" then
            print("attr:", ts.get_node_text(child2, buf))
            local nt = ts.get_node_text(child2, buf)

            -- TODO: loop attrs and ensure that all have a match. If has_single_match
            -- then abort.

            if child2_second:type() == "string" then
              -- FIX: child2_second:named_child() needs to be nil checked!!

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
              print(
                string.format(
                  "A (%s): dot index expression, ci_named = %s, %s",
                  indexed,
                  ci_named,
                  child2_text
                )
              )
            elseif child2_type == "string" then
              -- match against `string_content` literally.
              local ct = ts.get_node_text(child2:named_child(), buf)
              if ct == keybind.keys then
                valid = true
                print(
                  string.format(
                    "A (%s): keybind.keys, ci_named = %s, %s",
                    indexed,
                    ci_named,
                    child2_text
                  )
                )
              elseif ct == get_last_char(keybind.keys) then
                valid = true
                print(
                  string.format(
                    "A (%s): keybind.keys (last char), ci_named = %s, %s",
                    indexed,
                    ci_named,
                    child2_text
                  )
                )
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
      print("indexed > 1 | Captured table >>>", ts.get_node_text(capture_node, buf))
    end

    -- print("children #:", ci, ci_named)

    cnt = cnt + 1
  end

  return t_captured_candidates
end

--- Expects a doom keybind table_constructor node as input. It can be either
--- a leaf or a branch.
local function check_has_parent_branch_match(current_char, node_in, opts, build_msg)
  -- TODO:
  -- local status, gp = check_grand_parent(node, type)
  -- get_douple_grand_parent_tbl_ctks()tod

  -- Check that grand parent 1 and 2 are table constructs
  local grand_parent_1 = node_in:parent():parent()
  local correct_gp1
  if grand_parent_1:type() == "table_constructor" then
    correct_gp1 = true
  end

  local grand_parent_2 = grand_parent_1:parent():parent()
  local correct_gp2
  if grand_parent_2:type() == "table_constructor" then
    correct_gp2 = true
  end

  -- msg(
  --   string.format(
  --     "---- grand parent %s of %s---------------------",
  --     i,
  --     #leaf_candidates_filtered
  --   )
  -- )
  -- msg(ts.get_node_text(grand_parent_2, opts.buf))

  build_msg("gp: %s %s", correct_gp1, correct_gp2)

  local invalid = false

  if correct_gp1 and correct_gp2 then
    -- B. check that grand parent 2 has two indexed fields,
    -- AND optionally one extra field identifier called "name" == <string>

    -- TODO: is_keybind_branch()
    local indexed = 0
    for gp2_child in grand_parent_2:iter_children() do
      local gp2c_named_child_count = gp2_child:named_child_count()

      if gp2c_named_child_count > 3 then
        return false
      end

      -- check for the first indexed occurence.
      if gp2_child:named() and gp2_child:type() == "field" then
        local gp2c_first_child = gp2_child:named_child()
        local gp2c_first_child__type = gp2_child:named_child():type()

        -- if child2_type == ""
        -- TODO: check_field_identifier(..., <check_identifier>, <check_value>)

        if gp2c_first_child__type == "identifier" then
          local gp2c_second_child = gp2_child:named_child(1)

          local text__field_identifier_name = ts.get_node_text(gp2c_first_child, opts.buf)
          local text__field_identifier_value =
              ts.get_node_text(gp2c_second_child:named_child(), opts.buf)
          -- build_msg(
          --   "text__ %s",
          -- text__field_identifier_name
          -- )

          if
              text__field_identifier_name == "name"
              and gp2c_second_child:type() == "string"
          then
            build_msg(
              "branch name identifier [name] == [%s]",
              text__field_identifier_name
            )
          else
            build_msg("? not name and second is string")
            invalid = true
          end
        elseif

        -- else
        --   build_msg("")
        --   invalid = true
        -- end
        -- TODO: check_indexed_fields()

            indexed == 0 and gp2c_first_child__type == "string"
        then
          local string_content =
              ts.get_node_text(gp2c_first_child:named_child(), opts.buf)
          if current_char ~= string_content then
            build_msg("branch char mismatch!!")
            invalid = true
          end

          build_msg(
            ">>> real: %s, found gp: %s",
            current_char,
            -- opts.keys_parsed[#opts.keys_parsed - 1],
            ts.get_node_text(gp2c_first_child, opts.buf)
          )
          indexed = indexed + 1
        elseif indexed == 1 and gp2c_first_child__type == "table_constructor" then
          indexed = indexed + 1
        else
          invalid = true
        end
      end
    end

    build_msg("invalid = " .. tostring(invalid))
  end

  if not invalid then
    return grand_parent_2
  else
    return false
  end
end

--
-- NOTE: We know that the candidates are in the correct file, so now
-- we want to check if any of them are having a full branch match.
-- IF NONE of them have a branch match, that means that the binds are
-- dynamically put together, this means that we have throw
-- up a telescope picker that allows you to choose the ambiguous
-- candidates, but IRL this should be very uncommon..
--
-- For a given leaf table, check if the input target keybind
-- has a full match with the branch bubbling up from the leaf?
-- So, that we can determine which leaf candidate that has a
-- full or better match with the input target.
--
-- Input can be either a leaf or a branch node...
--
---If we find a matching branch then return this candidate or false.
---@return table|false
local function check_for_full_branch_match(opts, node_in, build_msg)
  local prev_br_node

  -- try to bubble up keys_parsed backwards in the syntax tree.
  for i = #opts.keys_parsed - 1, 1, -1 do
    local current_char = opts.keys_parsed[i]
    prev_br_node =
        check_has_parent_branch_match(current_char, prev_br_node or node_in, opts, build_msg)

    build_msg("type prevh_br_node " .. type(prev_br_node))

    if not prev_br_node then
      return false
    end
  end

  return true
end

-- Given a selected keybind try to  find the keybind leaf table
-- that matches it.
-- 1. First check for leaf candidates, and then
-- 2. Compare branch/leader branch nodes.
M.get_match_for_keybind = function(opts)
  if opts == nil then
    log.debug("opts cant be nil for nest/main.get_match_for_keybind()")
    return
  end
  opts.buf = dui_utils.get_buf_handle(opts.module_path)
  opts.messages = {}

  local build_msg = utils.new_message_builder(opts.messages)

  local leaf_candidates = get_keybind_leaf_candidates(opts.buf, opts.keybind)

  build_msg("keybind.keys = " .. opts.keybind.keys)
  build_msg("keybind.descr = " .. opts.keybind.description)

  build_msg("parsed:" .. vim.inspect(parse_key_sequence(opts.keybind.keys)))
  build_msg("=================================")
  build_msg("[ CHECK NAMED IDENTIFIER MATCHES ]")
  build_msg("captured nodes #:" .. #leaf_candidates)

  -- FIX: This check for attr matches should be done directly in the
  -- leaf candidate finder func.
  local leaf_candidates_filtered = {}
  for i, v in ipairs(leaf_candidates) do
    local count_mismatches = 0
    local text = ts.get_node_text(v.table, opts.buf)
    build_msg("----" .. ts.get_node_text(v.table, opts.buf) .. "----")
    for _, value in ipairs(__attrs) do
      build_msg(value .. " > " .. tostring(v.named_attrs[value .. "_match"]))
      if v.named_attrs[value .. "_match"] == false then
        count_mismatches = count_mismatches + 1
      end
    end
    if count_mismatches == 0 then
      table.insert(leaf_candidates_filtered, v)
    end
  end

  build_msg("=================================")

  -- 1. we have candidates that match the leaf pattern.
  -- 2. this means that if the binding resides in side a branch, then:
  --    i. it has a grand parent table constructor
  --        with all the leaf/ branch children
  -- TODO: This means that we have found a true parent branch,
  -- TODO: Now refactor this into a helper for getting / checking the Nth
  --        parent branch

  -- add nil checks??

  if #leaf_candidates_filtered == 0 then
    return false
  end

  local t_full_branch_matches = {}

  if #opts.keys_parsed > 1 then

  if #leaf_candidates_filtered > 1 then
    build_msg("[ BRANCH MATCHING ]")
    for i, t_leaf in ipairs(leaf_candidates_filtered) do
      build_msg("\n:: bubble branch %s ::", i)
      local ok = check_for_full_branch_match(opts, t_leaf.table, build_msg)
      if ok then
        table.insert(t_full_branch_matches, t_leaf)
      end
    end
  end

  else
    t_full_branch_matches=leaf_candidates_filtered
  end

  build_msg("=================================")
  build_msg("[ CAPTURED STRUCTURE (CAPTURED LEAVES..) ]")
  build_msg(vim.inspect(leaf_candidates_filtered[1]))
  build_msg("Num full matches: " .. #t_full_branch_matches)

  -- for _, v in ipairs(leaf_candidates_filtered) do
  --   build_msg( vim.inspect(v) )
  --   -- build_msg(ts.get_node_text(v.table, opts.buf))
  -- end

  opts.final_match = t_full_branch_matches
  return opts
end

-- if vim.g.mapper_action_on_enter == "definition" and vim.g.mapper_modules_dir then
M.mapper = function(opts)
  local function prepare_args(keybind)
    return {
      module_path = get_abs_path_from_module_origin(keybind),
      keybind = keybind,
      keys_parsed = parse_key_sequence(keybind.keys),
    }
  end

  local function open(args)   -- open file in split
    -- vim.cmd("set splitright")
    -- vim.cmd(string.format("vsplit %s", module_path))
    -- vim.cmd("set splitright!")
    vim.cmd(string.format("e %s", args.module_path))
    vim.cmd("stopinsert")
  end

  opts = vim.tbl_extend("force", opts or {}, {
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      map({ "i", "n" }, "<C-s>", function()
        _G.__monitor_doom_debug_binds = prepare_args(action_state.get_selected_entry())
        actions.close(prompt_bufnr)
      end, { desc = "Set the global __monitor_<name> var." })

      actions.select_default:replace(function()
        local args = prepare_args(action_state.get_selected_entry())
        if not args.module_path then
          log.info("nest telescope -> did not return a proper module_path")
          return
        end
        actions.close(prompt_bufnr)

        open(args)

        -- Bind the output to the buffer monitor module so that we can
        -- use the output as the value for the output to the buff monitor.
        _G.__monitor_doom_debug_binds = args

        local ret = M.get_match_for_keybind(args)

        -- print("full branch matches = ", vim.inspect(ret.final_match))

        -- -- move cursor
        if ret and #ret.final_match > 0 then
          -- print("range of bind table [1]:", vim.inspect(q[1].range)) -- , vim.inspect(leader)

          local table_node = ret.final_match[1].table

          local range = { table_node:range() }

          b.set_cursor_to_buf(ret.buf, range)

          -- local ts_utils = require("nvim-treesitter.utils")
          -- ts_utils.goto_node(ret.final_match[1].table)
        else
          print("no bind table found")
        end
      end)

      return true
    end,
  })

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
