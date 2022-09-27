
--
-- RECURSE TREESITTER VERSION --
--

-- wip / unused
--
-- Currently this is a treesitter func that parses a leader tree
-- recursively via TSNodes.
--
-- It expects the first `table_constructor` field within the
-- <leader> table.
--
-- should we keep this as stand alone. or merge this into
-- recurse so that the `recurse` function becomes treesitter
-- compatible, which would be quite based
--
-- This would mean generalizing `recurse_ts` ingo `recurse` above.
--
-- This would be necessary (and a useful exercise) in order to be able
-- to access disabled modules since those aren't loaded, or require
-- all modules upon calling `dui`, however, in that case, we could
-- use the exact same tree recurse call in both `core/config` and
-- insed of `mod/utils.extend()`
--
-- this would also give us flexibility in the future. knowing that we
-- have utils to easilly scan modules with ts.
--
-- nvim-treesitter has some recursive utils as well. check em out.
--
M.recurse_ts = function(buf, node, accumulated, level)
  -- note: is level even used? should use the same stack pattern?
  if accumulated == nil then
    accumulated = {
      level = 0,
    }
  else
    accumulated.level = level + 1
  end
  accumulated["container"] = node
  -- print(level, "--------------------------------------------")
  if node:type() == nil or node:type() ~= "table_constructor" then
    return false
  end
  -- FIX: put in state table
  local cnt = 1 -- child counter
  local special_cnt = 0
  local second_table
  local second_table_idx
  local second_table_cnt = 0
  local rhs
  local name_found
  local mode_found
  local opts_found
  local desc_found
  -- FIX: redo with iter_named_children()
  for n in node:iter_children() do
    if n:named() then
      local the_node = n:named_child(0) -- table constructor
      local the_type = the_node:type(0)
      if cnt == 1 then
        if the_type == "table_constructor" then
          -- accumulated["children"] = {}
          local child_table = {
            doom_category = "binds_table",
          }
          for child in node:iter_children() do
            if child:named() then
              if child:type() == "field" then
                table.insert(
                  child_table,
                  M.parse_nest_tables_meta_data(buf, child:named_child(0), {}, accumulated.level)
                )
              end
            end
          end
          table.insert(accumulated, child_table)
          return accumulated
        else
          accumulated["prefix"] = the_node
          accumulated["doom_category"] = "binds_leaf"
          local nt = tsq.get_node_text(the_node, buf)
          accumulated["prefix_text"] = nt

          special_cnt = special_cnt + 1
        end
      end
      if cnt ~= 1 then
        if the_type == "table_constructor" then
          second_table = the_node
          second_table_idx = special_cnt
          second_table_cnt = second_table_cnt + 1
        end
      end
      if
        cnt == 2
        and (
          the_type == "string"
          or the_type == "function_definition"
          or the_type == "dot_index_expression"
        )
      then
        rhs = the_node
      end
      local c2 = n:named_child(0)
      if c2:type() == "identifier" then
        local nt = tsq.get_node_text(c2, buf)
        if nt == "name" then
          accumulated["name"] = c2
          name_found = true
          special_cnt = special_cnt + 1
        elseif nt == "mode" then
          accumulated["mode"] = c2
          mode_found = true
          special_cnt = special_cnt + 1
        elseif nt == "description" then
          accumulated["description"] = c2
          desc_found = true
          special_cnt = special_cnt + 1
        elseif nt == "options" then
          accumulated["options"] = c2
          opts_found = true
          special_cnt = special_cnt + 1
        else
          rhs = the_node
        end
      end
      cnt = cnt + 1
    end
  end
  if accumulated.name == nil and special_cnt >= 3 then
    accumulated["name"] = node:named_child(2)
  end
  if accumulated.description == nil and special_cnt >= 4 then
    accumulated["description"] = node:named_child(3)
  end
  if accumulated.rhs == nil and second_table then
    rhs = second_table
    accumulated["doom_category"] = "binds_branch"
  end
  accumulated["rhs"] = rhs
  if accumulated.rhs:type() == "table_constructor" then
    accumulated["rhs"] = M.parse_nest_tables_meta_data(buf, accumulated.rhs, {}, level)
  end
  return accumulated
end

