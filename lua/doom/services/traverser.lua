--
-- TRAVERSER
--

-- TODO: documentation

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

return tree_traverser
