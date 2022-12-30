-- Hey @molleweide, sorry for the delay reviewing this and thank you for the
-- PR. I think that generalising tree traversal is a good idea but there are
-- some issues with this implementation. I think the big thing is it's a bit
-- too featureful to go in utils right now (meant for lightweight, general,
-- re-usable functions). There are also some issues with seperation of concerns
-- where there tree knows how to handle modules.lua files, loaded modules and
-- keybinds maps, I think it's trying to do too much and it needs to be broken
-- out a bit.

-- One way of doing this would be to make tree.lua a tree traversal builder.
-- That allows us to easily define tree traversals for whatever our use case. I
-- think this will make it easier to re-use code, make it easier to read and
-- debug, and provide more specific error messages for whatever tree we're
-- traversing.

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

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
-- EXAMPLE OF TRAVERSING MODULES
--

-- This example implements depth first traversal of doom modules

-- Here we define a new traverser for doom modules, instead of being responsible for the
-- traversal of the tree itself, tree_traverser allows us to build a custom traversal algorithm specifically for our use case.

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
      for key, value in pairs(node) do
        traverse_in(key, value) -- Traverse into next layer
      end
    elseif type(node) == "string" and not parent_is_section then
      print(node)
      traverse_out() -- This is a leaf, traverse back a layer
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

-- Example modules
local modules = {
  features = {
    "feature_test",
  },
  langs = {
    "language_test",
    -- 1,
    -- { "error" },
    -- nil,
  },
  -- 2,
  -- { "error" },
  -- nil,
}

-- The second variable is a function to handle each node where we can implement the node handling logic and do the task we need.
-- modules_traverser can be re-used anytime we want to iterate over a modules structure now.
modules_traverser(modules, function(node, stack)
  if type(node) == "string" then
    local path = vim.tbl_map(function(stack_node)
      return type(stack_node.key) == "string" and stack_node.key or stack_node.node
    end, stack)
    local path_string = "doom.modules." .. table.concat(path, ".")

    print(path_string)
  else
  end
end, { debug = doom.logging == "trace" or doom.logging == "debug" })

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- I really appreciate the code that you have written so far and the ideas for
-- this generalised traverser. I think for this to be worth it it needs to be
-- adaptable enough to work for other recursive structures (keymaps,
-- autocommands, commands). Currently this PR feels like it's adding more
-- complexity than needed to doom-nvim (my proposed solution does a bit as
-- well) and I think the goal should be not to increase LOC too much and write
-- something that is a lot simpler to read.

-- Also some more general feedback

-- Use string.rep to build indentation I don't think it's worth having multiple
-- logging levels for the debug mode, I think just leave it as trace and debug
-- Maybe instead of a filter there can be a skip() function? Not sure if prev()
-- will already cover this use-case. Make sure that new functions in utils do
-- not have too specific a use-case, I believe that a lack of structure is a
-- lot better than "too much" structure (i.e. a function can only be used on a
-- very specific data structure). Try to clean up code where possible, use more
-- ternarary operators for simple checks, if a function has a lot of if
-- statements or deep nesting see if it can be shortened Try to think about the
-- most common use case (in this situation it'd be loading modules as fast as
-- possible, no debugging, no printing, etc) Try to make any computation
-- unrelated to the main use-case optional so we're not running unnecessary
-- code I hope this isn't too much feedback, I think generally it just needs
-- better seperation of concerns, adaptability and not to run unecessary code
-- for the main use case.
