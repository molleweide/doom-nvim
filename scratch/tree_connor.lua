--
-- TRAVERSER
--

local log = require("doom.utils.logging")
local tree_traverser = {
  build = function(builder_opts)
    local traverser = builder_opts.traverser
    local debug_node = builder_opts.debug_node
    local stack = {}
    local result = {}

    -- Traverse out, pops from stack, adds to result
    local traverse_out = function()
      table.remove(stack, #stack)
    end

    -- Error does not add to result or anything
    local err = function(message)
      table.remove(stack, #stack)
      local path = vim.tbl_map(function(stack_node)
        return "[" .. vim.inspect(stack_node.key) .. "]"
      end, stack)
      print(("%s\n Occursed at key `%s`."):format(message, table.concat(path, "")))
      table.remove(result, #result)
    end

    local traverse_in
    traverse_in = function(key, node)
      table.insert(stack, { key = key, node = node })
      table.insert(result, { node = node, stack = vim.deepcopy(stack) })
      traverser(node, stack, traverse_in, traverse_out, err)
    end

    return function(tree, handler, opts)
      result = {} -- Reset result

      traverser(tree, stack, traverse_in, traverse_out, err)

      if opts.debug and debug_node then
        for _, value in ipairs(result) do
          debug_node(value.node, value.stack)
        end
      end

      for _, value in ipairs(result) do
        handler(value.node, value.stack)
      end
    end
  end,
}

--
-- MODULES TABLE
--

-- This example implements depth first traversal of doom modules

-- Here we define a new traverser for doom modules, instead of being
-- responsible for the traversal of the tree itself, tree_traverser allows us
-- to build a custom traversal algorithm specifically for our use case.

local modules_traverser = tree_traverser.build({
  -- Builds the traversal function defining how we should move through the tree
  -- @param node any The node itself
  -- @param next function(node: any) Traverse into the traverse_in node, adding the node to the stack
  -- @param traverse_out function() Traverses back a depth, pops the value from the stack
  -- @param err function(message: string) Traverses back a depth, this value is skipped by the handler (see below)
  traverser = function(node, stack, traverse_in, traverse_out, err)
    local parent = stack[#stack]
    local parent_is_section = (
      parent == nil or (type(parent.key) == "string" and type(parent.node) == "table")
    )
    if type(node) == "table" and parent_is_section then
      if vim.tbl_count(node) == 0 then
        traverse_out() -- Handle case if a table is empty.
      else
        for key, value in pairs(node) do
          traverse_in(key, value) -- Traverse into next layer.
        end
        traverse_out() -- Travel back up when a sub table has been completed.
      end
    elseif type(node) == "string" and not parent_is_section then
      traverse_out() -- This is a leaf, traverse back a layer.
    else
      err(
        ("doom-nvim: Error traversing doom modules in `modules.lua`, unexpected value `%s`."):format(
          vim.inspect(node)
        )
      ) -- Traverse back a layer but do not pass this value to the handler function.
    end
  end,
  -- Optional debugging function that can be used to
  debug_node = function(node, stack)
    local parent = stack[#stack]
    local indent_str = string.rep("--", #stack)
    local indent_cap = type(node) == "table" and "+" or ">"
    print(("%s%s %s"):format(indent_str, indent_cap, type(node) == "table" and parent.key or node))
  end,
})

local m = {
  FEATURES = {
    "feature_test",
    "feature_test2",
    EMPTY = {}, -- also handles this case, just in case...
    XXX = {
      "x1",
      "x2",
      YYY = {
        "aaa",
        "bbb",
        "ccc",
      },
    },
  },
  LANGS = {
    "language_test",
    "language_test2",
    -- 1,
    -- { "error" },
    -- nil,
  },
  -- 2,
  -- { "error" },
  -- nil,
}
local dm = require("doom.core.modules").enabled_modules

-- TODO: where to put this one?
--        dry: It is a recurring pattern

-- The second variable is a function to handle each node where we can implement
-- the node handling logic and do the task we need. modules_traverser can be
-- re-used anytime we want to iterate over a modules structure now.
modules_traverser(m, function(node, stack)
  if type(node) == "string" then
    local path = vim.tbl_map(function(stack_node)
      return type(stack_node.key) == "string" and stack_node.key or stack_node.node
    end, stack)
    -- P(path)
    local path_string = table.concat(path, ".")
    -- Each module name
    -- P(stack[#stack])
    -- Full mod path
    -- print(path_string)
  end
end, { debug = doom.settings.logging == "trace" or doom.settings.logging == "debug" })

--
-- MODULES LOADED
--

local modules_loaded = tree_traverser.build({
  traverser = function(node, stack, traverse_in, traverse_out, err)
    if node.type == "doom_module_single" then
      traverse_out()
    elseif type(node) == "table" then
      for key, value in pairs(node) do
        traverse_in(key, value) -- Traverse into next layer.
      end
      traverse_out() -- Travel back up when a sub table has been completed.
    else
      err(
        ("doom-nvim: Error traversing `doom.modules`, unexpected value `%s`."):format(
          vim.inspect(node)
        )
      ) -- Traverse back a layer but do not pass this value to the handler function.
    end
  end,
  -- Optional debugging function that can be used to
  debug_node = function(node, stack)
    local parent = stack[#stack]
    local indent_str = string.rep("--", #stack)
    local indent_cap = type(node) == "table" and "+" or ">"
    print(("%s%s %s"):format(indent_str, indent_cap, type(node) == "table" and parent.key or node))
  end,
})

modules_loaded(doom.modules, function(node, stack)
  if node.type then
    P(stack, 3)
    local t_path = vim.tbl_map(function(stack_node)
      return type(stack_node.key) == "string" and stack_node.key
    end, stack)
    P(t_path)
    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
  end
end, { debug = doom.settings.logging == "trace" or doom.settings.logging == "debug" })
