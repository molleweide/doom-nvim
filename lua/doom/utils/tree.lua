-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- TODO
--
--------------------------------------
-- RENAME: LEAF > NODE; BRANCH > EDGE; EDGE > FILTER; filter_ids > node_ids
--
--------------------------------------
-- logger > print each inspect entry on new line \n
--    so that it becomes extra easy to compare
--
--------------------------------------
-- use metatable?
--
--------------------------------------
-- functional chaining
--
-- make it possible to
--
-- local res = crawl(opts).crawl()
--
--------------------------------------
--  entry_counter, leaf_counter, edge_counter.
--
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  ARGS | HOW YOU CAN USE CALL `TRAVERSE()`
--
-- print(minimumvalue(8,10,23,12,5))
--
-- print(minimumvalue(1,2,3))
--
--
-- # 0 --------------------------
--
--    crawl default tree > requires setup configuration
--
--
-- # 1 -------------------------------------------------------
--
--    1 table = options
--
--    1 string = filter default
--      load `string` defaults
--
--    1 func = returns options table
--
--
-- # 2 -------------------------------------------------------
--
--      1 table = options,
--      2 table = accumulator
--
--      1 table = opts
--      2 string = filter
--
--      1 table
--      2 function
--
--
-- # 3 -------------------------------------------------------
--
--      acc = crawl(tree, filter, acc)
--
--      1 table = tree
--      2 function|string' =
--      3 table = accumulator
--
--      allows for quickly traversing a tree and flattening out all nodes
--      to a list easilly
--
-- # 4 -------------------------------------------------------
--
--      1 table = tree
--      2 function|string' =
--      3 table = accumulator
--      4
--
-- -----------------------------------------------------------------------------
--
-- _WARNING: if you are using a string filter arg, you have to make sure it is
-- one of the special keywords, or it will be treated as a match string for
-- computing nodes, see XXX.
--
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--
--  OPTIONS
--
--  ::: option (new name ideas) :::
--
--  ::: tree (required) :::
--
--  ::: max_level :::
--
--  ::: acc :::
--
--  ::: leaf -> node (do|nodes|node_apply|process_node) :::
--
--  ::: branch -> edge (edges|process_edge) :::
--
--  ::: branch_next -> next_subtable (edge_next|subtable) :::
--
--    if there is a specific way that you access the next entry to analyze
--    within RHS if rhs == table
--
--
--  ::: edge -> filter (filter/separator/determine_node) :::
--
--      callback determine if tree entry is node or branch
--
--      FUNCTION
--
--      TABLE
--
--      STRING
--        special keyword  := string|list
--
--  ::: filter_ids -> node_ids (filter_props|node_ids|filter_ids) :::
--
--      IS THIS A SPECIAL CASE OF `FILTER` BELOW WHERE THE TYPE(ARG) == "TABLE"???.
--      THIS WOULD SIMPLIFY THINGS QUITE A LOT...
--
--      table array containing predefined properties that you know identifies a leaf.
--      Eg. doom module parts. See `core/spec.module_parts`
--      pass a list of specific attributes that you know constitutes a leaf node
--      and filter on this
--
-- -- callback function used to identify a leaf
-- --
-- -- special keywords: (string, list)
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local M = {}

--
-- A COUPLE OF HELPER FUNCTIONS THAT SHOULD BE CONSIDERED MOVAL INTO SOME OTHER LOCATION MAYBE.
--

--- conatenate path stack with node
--- rename: flatten_stack is a non descriptive name -> concat_node_path()
local function flatten_stack(stack, v)
  local pc = { v }
  if #stack > 0 then
    pc = vim.deepcopy(stack)
    table.insert(pc, v)
  end
  return pc
end

-- Helper for attaching data to a specific table path in `head` table. Eg. `doom.modules`
-- could be a head if you want to append all modules upon loading doom.
--
-- @param table list of path components
M.attach_table_path = function(head, tp, data)
  local last = #tp
  for i, p in ipairs(tp) do
    if i ~= last then
      if head[p] == nil then
        head[p] = {}
      end
      head = head[p]
    else
      head[p] = data
    end
  end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local function compute_indentation(stack, sep, mult)
  local a = ""
  local b = ""
  mult = mult or 1
  for _ = 1, #stack do
    a = a .. sep
  end
  for _ = 1, mult do
    b = b .. a
  end
  return b
end

--
-- WIP: TREE LOG/DEBUG HELPER
--

-- At the moment (1) below is probably the most reliable.
-- The goal is to make `large_pretty` for debugging large trees with colors n stuff.
--
-- i. within count range. always keep a count and only print nodes [x - y]
-- ii. levels range
-- iii. print colors
--
-- eg.
-- log = {
--   use = true,
--   mult = 8,
--   name_string = "test list modules",
--   cat = 1,
--   inspect = true,
--   new_line = true,
--   frame = true,
--   separate = true,
-- },

-- 1 = log all
-- 2 = log only branch and leaf
-- 3 = only leaves
-- 4 = only branches
-- 5 = only edge data
--
-- ::: LOGGING DEFAULTS :::
--
-- nodes
-- edge
-- mini | minimal
-- all | both | base | default
-- full | inspect
-- pretty
-- large_pretty: large prints where each entry is printed with a nice frame and colors so that
--    you can truly see what is happening.
--    Or open up a split that writes this as a temporary file with highlights and everything so that you can truly debug easilly.
--
--
--  create a frame around the tree so that you can make very descriptive logs on large screens
--
local function logger(is_node, opts, stack, k, v)
  -- use table pattern to make the messages more variable and dynamic.
  --
  -- NOTE: FRAME -> LOOK AT HOW VENN.NVIM IS WRITTEN

  local msg = { entry = {}, rhs = { data = "", state = "" } }

  if not opts.log.use then
    return
  end

  local iters = opts.log.iters or (#stack + 1)
  if #stack + 1 ~= iters then
    return
  end

  local cat = opts.log.cat or 2

  -- use these to compute a frame for the tree.
  local num_col = 0
  local num_lines = 0

  local all = cat == 1
  local full = cat == 2
  local ind = compute_indentation(stack, " ", opts.log.mult)
  local edge_shift = "      "
  local pre = edge_shift .. ind
  local points_to = " : "

  local post_sep = opts.log.new_line and ("\n     " .. pre) or " / "

  -- local ind_str = "+" and is_node or "-"

  -- todo: LEAF / BRANCH merge into one statement!!!
  if is_node and (all or full or cat == 3) then
    msg.entry = string.format(
      [[%s %s > (%s) %s %s]],
      "+",
      compute_indentation(stack, "+", opts.log.mult),
      #stack,
      k.val,
      v.val
    )
  end

  if not is_node and (all or full or cat == 4) then
    msg.entry = string.format(
      [[%s %s > (%s) %s %s]],
      "-",
      compute_indentation(stack, "-", opts.log.mult),
      #stack,
      k.val,
      v.val
    )
  end

  print(msg.entry)
  ------------------------------------

  if all or cat == 5 then
    msg.lhs = { data = "", state = "" }
    for key, value in pairs(k) do
      if key ~= "val" then
        msg.lhs.state = msg.lhs.state .. tostring(key) .. points_to .. tostring(value) .. post_sep
      else
        msg.lhs.data = msg.lhs.data .. type(value) .. points_to .. value
      end
    end
    if opts.log.inspect then
      print(pre .. " ld: " .. msg.lhs.data)
    end
    print(pre .. " ls: " .. msg.lhs.state)

    msg.rhs = { data = "", state = "" }
    for key, value in pairs(v) do
      if key ~= "val" then
        msg.rhs.state = msg.rhs.state .. tostring(key) .. points_to .. tostring(value) .. post_sep
      else
        if type(v.val) == "table" then
          for i, j in pairs(value) do
            msg.rhs.data = msg.rhs.data .. i .. points_to .. tostring(j) .. post_sep
          end
        else
          msg.rhs.data = msg.rhs.data .. type(value) .. points_to .. tostring(value)
        end
      end
    end

    if opts.log.inspect then
      print(pre .. " rd: " .. msg.rhs.data)
    end
    print(pre .. " rs: " .. msg.rhs.state)
  end

  if opts.log.separate then
    print("\n")
  end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- compute state of left and right hand sides of the key value pair for each table entry.

local function check_lhs(l)
  return {
    val = l,
    is_num = type(l) == "number",
    is_str = type(l) == "string",
  }
end

local function check_rhs(r, opts)
  local t = type(r)
  local ret = {
    val = r,
    is_fun = t == "function",
    is_tbl = t == "table",
    is_str = t == "string",
    is_num = t == "number",
    str_empty = r == "",
    id_match = false,
    numeric_keys = false,
    num_keys = nil,
  }
  if ret.is_tbl then
    local num_keys = 0
    for k, _ in pairs(r) do
      num_keys = num_keys + 1
      if opts.filter_ids then
        if vim.tbl_contains(opts.filter_ids, k) then
          ret.id_match = true
        end
      end
      ret.numeric_keys = type(k) == "number"
    end
    ret.num_keys = num_keys
    ret.tbl_empty = num_keys == 0
  end
  return ret
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- todo: add counters that keep track of all kinds of relevan data for a table
M.recurse = function(opts, tree, stack, accumulator)
  accumulator = accumulator or {}
  stack = stack or {}

  -- TODO: assert tree == table or return and run logger on the previous entry

  for k, v in pairs(tree) do
    local left = check_lhs(k)
    local right = check_rhs(v, opts)
    local is_node = opts.filter(opts, left, right)

    logger(is_node, opts, stack, left, right)

    -- TODO: increment `counter_entry`

    if not is_node then
      -- TODO: increment `counter_branch`
      stack, accumulator = M.process_branch(opts, k, v, stack, accumulator)
      -- opts.branch(stack, k, v)
      -- -- table.insert(accumulator, ret)
      -- table.insert(stack, k)
      -- M.recurse(opts, v, stack, accumulator)
      -- return stack, accumulator
    else
      -- TODO: increment `counter_leaf`
      stack, accumulator = M.process_leaf(opts, k, v, stack, accumulator)
      -- local ret = opts.node(stack, k, v)
      -- table.insert(accumulator, ret)
      -- return stack, accumulator
    end
  end

  table.remove(stack, #stack)
  return accumulator
end

M.process_branch = function(opts, k, v, stack, accumulator)
  opts.branch(stack, k, v)
  -- table.insert(accumulator, ret)
  table.insert(stack, k)

  -- TODO: need to be able to determine which prop to recurse down!!!
  --
  -- a. select which prop to recurse down.
  -- b. should this be the same table as the one we return?

  -- M.recurse(opts, v, stack, accumulator)
  M.recurse(opts, opts.branch_next(v), stack, accumulator)

  return stack, accumulator
end

-- todo: maybe default should be to return `v`,
-- eg. if opts.node ... else insert v
M.process_leaf = function(opts, k, v, stack, accumulator)
  local ret = opts.node(stack, k, v)
  table.insert(accumulator, ret)
  return stack, accumulator
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- TODO: USE ... TO MANAGE VARIABLE ARGS
--
-- ARGS SYNTAX EXAMPLE
--
-- function minimumvalue (...)
--    local mi = 1 -- maximum index
--    local m = 100 -- maximum value
--    local args = {...}
--    for i,val in ipairs(args) do
--       if val < m then
--          mi = i
--          m = val
--       end
--    end
--    return m, mi
-- end
M.traverse_table = function(opts, tree, acc)
  opts = opts or {}
  tree = opts.tree or tree
  if not opts.log then
    opts.log = {}
  end

  -- TODO: PUT ALL THESE SETUP STATEMENTS IN A METATABLE??

  -- TREE -----------------------------------------------------------------------------
  --
  if not tree then
    -- assert tree here to make sure it is passed.
    print("TREE ERROR > tree is required")
  end

  if type(tree) == "table" and #tree == 0 then
    -- return
  end

  if type(tree) == "function" then
    tree = tree()
  end

  -- OPTS.MAX_LEVEL -----------------------------------------------------------------------------

  opts.max_level = opts.max_level or 10

  -- ACCUMULATOR -----------------------------------------------------------------------------
  --
  ---     if you want to continue accumulating to an already existing list, then pass this
  ---     option.
  if opts.acc then
    acc = opts.acc or acc
    -- remove acc prop
  end

  -- LEAF DEFAULT CALLBACK -----------------------------------------------------------------------------
  --
  ---     how to process each node node
  ---     return appens to accumulator
  if not opts.node then
    opts.node = function(_, _, v)
      return v
    end
  end

  -- BRANCH DEFAULT CALLBACK -----------------------------------------------------------------------------
  --
  ---     how to process each branch node
  ---       return appens to accumulator
  if not opts.branch then
    opts.branch = function()
      return false
    end
  end

  if not opts.branch_next then
    opts.branch_next = function(v)
      return v
    end
  end

  -- LEAF IDS -----------------------------------------------------------------------------
  --
  --      table array containing predefined properties that you know identifies a node.
  --      Eg. doom module parts. See `core/spec.module_parts`
  --
  -- pass a list of specific attributes that you know constitutes a node node
  -- and filter on this
  opts.filter_ids = opts.filter_ids or false

  -- OPTS.EDGE -----------------------------------------------------------------------------
  --
  -- callback function used to identify a node
  --
  -- special keywords: (string, list)
  --
  if type(opts.filter) == "string" then
    if opts.filter == "list" then
      opts.filter = function()
        return true
      end
    elseif opts.filter == "settings" then
      opts.filter = function(_, l, r)
        return l.is_num or not r.is_tbl or r.numeric_keys or r.tbl_empty
      end
    else
      local flt_str = opts.filter
      opts.filter = function(_, _, r)
        return r.val.type == flt_str
      end
    end
  end

  -- default case if you leave filter empty.
  if not opts.filter then
    opts.filter = function(_, _, r)
      return not r.is_tbl
    end
  end

  if opts.log.frame then
    print("[---------" .. opts.log.name_string .. "---------]")
  end

  acc = M.recurse(opts, tree, {}, acc)

  if opts.log.frame then
    print("[------------------------------------------------]")
  end

  return acc
end

return M
