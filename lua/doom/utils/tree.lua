local M = {}

--- Concatenates the stack with the leaf node.
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
  for _ = 1, #stack do
    a = a .. sep
  end
  for _ = 1, mult do
    b = b .. a
  end
  return b
end

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
      --   -- inspect = true,
      --   frame = true,
      --   separate = true,
      -- },


-- 1 = log all
-- 2 = log only branch and leaf
-- 3 = only leaves
-- 4 = only branches
-- 5 = only edge data
local function logger(is_leaf, opts, stack, k, v)
  if not opts.log.use then
    return
  end

  local iters = opts.log.iters or (#stack + 1)
  if #stack + 1 ~= iters then
    return
  end

  local cat = opts.log.cat or 2

  local msg = ""
  local all = cat == 1
  local full = cat == 2
  local ind = compute_indentation(stack, " ", opts.log.mult)

  -- local ind_str = "+" and is_leaf or "-"

  -- LEAF / BRANCH
  if is_leaf and (all or full or cat == 3) then
    msg = string.format(
      [[%s > (%s) %s %s]],
      compute_indentation(stack, "+", opts.log.mult),
      #stack,
      k.val,
      v.val
    )
  end
  if not is_leaf and (all or full or cat == 4) then
    msg = string.format(
      [[%s > (%s) %s %s]],
      compute_indentation(stack, "-", opts.log.mult),
      #stack,
      k.val,
      v.val
    )
  end

  ------------------------------------

  local edge_shift = "      "

  -- EDGE
  if all or cat == 5 then
    local msg_l_inspect = ""
    local msg_r_inspect = ""
    local msg_l_state = ""
    local msg_r_state = ""

    -- print(vim.inspect(k.val))

    for key, value in pairs(k) do
      if key ~= "val" then
        msg_l_state = msg_l_state .. " / " .. tostring(key) .. ":" .. tostring(value)
      else
        msg_l_inspect = msg_l_inspect .. " / " .. type(value) .. ":" .. value
      end
    end

    for key, value in pairs(v) do
      if key ~= "val" then
        msg_r_state = msg_r_state .. " / " .. tostring(key) .. ":" .. tostring(value)
      else
        if type(v.val) == "table" then
          for i, j in pairs(value) do
            msg_r_inspect = msg_r_inspect .. " / " .. i .. ":" .. tostring(j)
          end
        else
          msg_r_inspect = msg_r_inspect .. " / " .. type(value) .. ":" .. tostring(value)
        end
      end
    end

    if opts.log.inspect then
      msg = msg .. "\n" .. edge_shift .. ind .. " L: " .. msg_l_inspect
    end
    msg = msg .. "\n" .. edge_shift .. ind .. " L: " .. msg_l_state
    if opts.log.inspect then
      msg = msg .. "\n" .. edge_shift .. ind .. " R: " .. msg_r_inspect
    end
    msg = msg .. "\n" .. edge_shift .. ind .. " R: " .. msg_r_state
  end

  print(msg)

  if opts.log.separate then
    print(" ")
  end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

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
      if opts.leaf_ids then
        if vim.tbl_contains(opts.leaf_ids, k) then
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

M.recurse = function(opts, tree, stack, accumulator)
  accumulator = accumulator or {}
  stack = stack or {}

  for k, v in pairs(tree) do

    local left = check_lhs(k)
    local right = check_rhs(v, opts)
    local is_leaf = opts.edge(opts, left, right)

    logger(is_leaf, opts, stack, left, right)

    if not is_leaf then
      stack, accumulator = M.process_branch(opts, k, v, stack, accumulator)
      -- opts.branch(stack, k, v)
      -- -- table.insert(accumulator, ret)
      -- table.insert(stack, k)
      -- M.recurse(opts, v, stack, accumulator)
      -- return stack, accumulator
    else
      stack, accumulator = M.process_leaf(opts, k, v, stack, accumulator)
      -- local ret = opts.leaf(stack, k, v)
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
  M.recurse(opts, v, stack, accumulator)
  return stack, accumulator
end

-- todo: maybe default should be to return `v`,
-- eg. if opts.leaf ... else insert v
M.process_leaf = function(opts, k, v, stack, accumulator)
  local ret = opts.leaf(stack, k, v)
  table.insert(accumulator, ret)
  return stack, accumulator
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- TODO: USE ... TO MANAGE VARIABLE ARGS
--
-- if # args == 1  -> opts table
--
-- if # args = 2 -> opts, acc
--
-- if arg1 == string -> edge,
M.traverse_table = function(opts, tree, acc)
  opts = opts or {}
  tree = opts.tree or tree
  if not opts.log then
    opts.log = {}
  end

  -- PUT ALL THESE SETUP STATEMENTS IN A METATABLE.

  if not tree then
    -- assert tree here to make sure it is passed.
    print("TREE ERROR > tree is required")
  end

  -- OPTS.TYPE
  --     specify which leaf pattern to use.
  --     Alternatives: ( "modules" | any module_part )

  opts.max_level = opts.max_level or 10

  -- ACCUMULATOR
  --
  ---     if you want to continue accumulating to an already existing list, then pass this
  ---     option.
  if opts.acc then
    acc = opts.acc or acc
    -- remove acc prop
  end

  -- LEAF DEFAULT CALLBACK
  --
  ---     how to process each leaf node
  ---     return appens to accumulator
  if not opts.leaf then
    opts.leaf = function(_, _, v)
      return v
    end
  end

  -- BRANCH DEFAULT CALLBACK
  --
  ---     how to process each branch node
  ---       return appens to accumulator
  if not opts.branch then
    opts.branch = function()
      return false
    end
  end

  -- LEAF IDS
  --
  --      table array containing predefined properties that you know identifies a leaf.
  --      Eg. doom module parts. See `core/spec.module_parts`
  --
  -- pass a list of specific attributes that you know constitutes a leaf node
  -- and filter on this
  opts.leaf_ids = opts.leaf_ids or false

  -- OPTS.EDGE
  --
  -- callback function used to identify a leaf
  if type(opts.edge) == "string" then
    local flt_str = opts.edge
    opts.edge = function(_, _, r)
      return r.val.type == flt_str
    end
  end

  -- default case if you leave edge empty.
  if not opts.edge then
    opts.edge = function(_, _, r)
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
