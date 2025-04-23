--
-- WRAPPER CLASS
--

local M = {}
M.TSNodeWrapper = { __name = "TSNodeWrapperClass" }

function M.make_wrapped_node(self, node)
    local tslua = self.__tslua or self

    if type(node.type) ~= "function" then
        return
    end

    local wrapper = tslua.subclasses[node:type()] or {}

    wrapper.__index = wrapper

    setmetatable(wrapper, {
        __index = setmetatable(M.TSNodeWrapper, {
            __index = tslua,
        }),
    })

    local instance = setmetatable({ _name = "TSNodeInstance", node = node }, wrapper)

    -- Make instance callable
    local mt = getmetatable(instance)
    mt.__call = M.make_wrapped_node

    return instance
end

-------------------------------------------------------------------------------

--
-- WRAPPER CLASS: SHARED METHODS
--
-- The following are methods defined on the wrapper class, which implements
-- generalized node operations that apply to all languages.
--

local TSNodeWrapper = M.TSNodeWrapper

-- TODO: rename the node to node_handler, and then use :node() to get the
-- raw node, or maybe use :raw() to get the node, and keep using [self.node]
function TSNodeWrapper:get_node()
    return self.node
end

function TSNodeWrapper:test(msg)
    print("test from TSNodeWrapper:", msg)
end

---Check if a ts proxy is of a certain type [check_type]
---@param check_type String The type we want to compare against
function TSNodeWrapper:is(check_type)
    return self.node:type() == check_type
end

-- TODO: rename to node() -> returns the raw node, so that one can do iter methods.
-- Which might be a bit trickier to play nicely with the wrapper.
function TSNodeWrapper:get_node()
    return self.node
end

function TSNodeWrapper:get_text()
    return vim.treesitter.get_node_text(self.node, self.buf_handle)
end

---Make it easy to move a node to another location after/before node X.
function TSNodeWrapper:move_to(opts) end

---Helper that prints context about node
function TSNodeWrapper:print_context(opts)
    -- ~ node type.
    -- ~ node text truncated if necessary
    -- ~ node range
    -- ~ node text first line
    -- ~ node text last line
    -- ~ node text full
    -- ~ preceeding line
    -- ~ line after.
    -- ~ is field??
end

---If a subclass does not have dedicated remove method, then we fallback to
---this default remover
function TSNodeWrapper:remove() end

-- function TSNodeWrapper:remove()
--   error("remove() not implemented for this node type: " .. self.node:type())
-- end

return M
