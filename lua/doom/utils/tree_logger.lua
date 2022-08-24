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

return function(is_node, opts, stack, k, v)
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
