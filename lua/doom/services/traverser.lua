--
-- TRAVERSER
--

-- TODO: More documentation

-- TODO: better naming. Since this is quite an advanced function, each
-- component needs to have a very intuitive name that makes you understand
-- instantly.

-- TODO: add a self.name to each traverser so that we can create better
-- debug statements.

-- Default debugger print
local default_debug_node = function(node, stack, opts)
    -- TODO: show leaves and branches differently
    local parent = stack[#stack]
    local indent_str = string.rep(":--", #stack - 1) or ""
    local indent_cap = type(node) == "table" and "+" or ">"
    print(
        ("recurse@%s # default: %s%s %s"):format(
            opts.name,
            indent_str,
            indent_cap,
            type(node) == "table" and parent.key or node
        )
    )
end

-- Default debug levels
local default_log_levels = { debug = false, name = "[anonymous traverser]" }

local tree_traverser = {
    ---Build a function that does what ??
    ---@param builder_opts table
    ---@return function
    build = function(builder_opts)
        local traverser = builder_opts.traverser
        local debug_node = builder_opts.debug_node or default_debug_node
        local stack = {}
        local result = {}

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

        -- WARN: I need to update the terminology because now it is a bit ambiguous.

        -- why is this local defined above here??
        local traverse_in

        traverse_in = function(key, node)
            table.insert(stack, { key = key, node = node })
            table.insert(result, { node = node, stack = vim.deepcopy(stack) })
            traverser(node, stack, traverse_in, traverse_out, err)
        end

        return function(tree, handler, opts)
            result = {} -- Reset result
            if opts == nil then
                opts = default_log_levels
            end

            traverser(tree, stack, traverse_in, traverse_out, err)

            if opts.debug and debug_node then
                for _, value in ipairs(result) do
                    debug_node(value.node, value.stack, opts)
                end
            end

            -- why does this have to be performed at the end, couldnt we just do
            -- this inside the `traverse_in` func??
            if handler then
                for _, value in ipairs(result) do
                    handler(value.node, value.stack)
                end
            end

            return result
        end
    end,
    build_ts = function(builder_opts)
        -- todo..
    end,
}

return tree_traverser
