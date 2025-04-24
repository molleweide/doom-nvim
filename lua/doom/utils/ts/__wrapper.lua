local M = {}
M.TSNodeWrapper = { __name = "TSNodeWrapperClass" }

function M.make_wrapped_node(self, input_node)
    if type(input_node.type) ~= "function" then
        return
    end
    local tslua = self.__tslua or self
    -- local is_first_call = rawget(self, "__tslua") == nil
    -- local tslua = is_first_call and self or rawget(self, "__tslua")
    if not tslua then
        error("No TSLua instance found for wrapped object")
    end

    local wrapper = tslua.subclasses[input_node:type()]
    if wrapper then
        wrapper.__name = "wrapper:" .. input_node:type()
    else
        wrapper = {}
        wrapper.__name = string.format("wrapper:%s (undefined)", input_node:type())
    end

    -- Set up wrapper inheritance
    wrapper.__index = wrapper
    setmetatable(wrapper, {
        -- BaseWrapper → tslua fallback
        __index = setmetatable(M.TSNodeWrapper, {
            __index = tslua,
        }),
    })

    local instance = { __name = "TSNodeInstance", __tslua = tslua, node_handle = input_node }
    return setmetatable(instance, {
        -- Lookup chain instance -> wrapper -> TSNodeWrapper -> TSLua -> TSNode
        __index = function(tbl, key)
            if wrapper[key] then
                return wrapper[key]
            end
            if M.TSNodeWrapper[key] then
                return M.TSNodeWrapper[key]
            end
            if tslua[key] then
                return tslua[key]
            end
            if tbl.node_handle and type(tbl.node_handle[key]) == "function" then
                print("<Accessing TSNode method>")
                local node_obj = tbl.node_handle
                -- This ensures that the TSNode is called with its proper "self".
                return function(_, ...)
                    return node_obj[key](node_obj, ...)
                end
            end
        end,
        -- Make instance callable
        __call = M.make_wrapped_node,
    })
end

-------------------------------------------------------------------------------

--
-- WRAPPER CLASS: SHARED METHODS
--
-- The following are methods defined on the wrapper class, which implements
-- generalized node operations that apply to all languages.
--

local TSNodeWrapper = M.TSNodeWrapper

function TSNodeWrapper:test(msg)
    print("test from TSNodeWrapper:", msg)
end

---Check if a ts proxy is of a certain type [check_type]
---@param check_type String The type we want to compare against
function TSNodeWrapper:is(check_type)
    -- doing [self:type()] here should also fallback to the TSNode:type()...
    return self.node_handle:type() == check_type
end

--Get wrapped node handle.
function TSNodeWrapper:node()
    return self.node_handle
end

---Get text from node
---Maybe this should be hidden with _get_text()
function TSNodeWrapper:get_text(node)
    return vim.treesitter.get_node_text(node, self.buf_handle)
end

---Get text from wrapped node_handle
function TSNodeWrapper:text()
    return vim.treesitter.get_node_text(self.node_handle, self.buf_handle)
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
