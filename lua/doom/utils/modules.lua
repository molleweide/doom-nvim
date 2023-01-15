-- NOTE: hosts some recurring traversers in doom

local M = {}


-- NOTE: loop over `enabled modules` table.

-- This example implements depth first traversal of doom modules

-- Here we define a new traverser for doom modules, instead of being
-- responsible for the traversal of the tree itself, tree_traverser allows us
-- to build a custom traversal algorithm specifically for our use case.

M.modules_table = tree_traverser.build({
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

-- TODO: loop over `doom.modules`
M.modules_loaded = tree_traverser.build({
})

return M
