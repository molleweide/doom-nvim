local M = {}
M.TSNodeWrapper = { __name = "TSNodeWrapperClass" }

function M.make_wrapped_node(self, input_node)
    if not input_node or type(input_node.type) ~= "function" then
        return
    end

    local tslua = self.__tslua or self

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

    -- Initialize wrapper instance
    return setmetatable({
        __name = "TSNodeInstance",
        __tslua = tslua,
        node_handle = input_node,
    }, {
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
                local node_obj = tbl.node_handle
                -- This ensures that the TSNode is called with its proper "self".
                return function(_, ...)
                    return node_obj[key](node_obj, ...)
                end
            end
        end,

        -- Make instance callable, ie. allow making new node wrappers from
        -- previous ones so that we can always keep the ball rolling once
        -- we have created the first node wrapper.
        __call = M.make_wrapped_node,

        -- Make wrapped TSNode's printable.
        __tostring = function(tbl)
            return tbl:text()
        end,

        -- I cannot get the __eq to trigger?!
        -- __eq = function(self, other)
        --         print("__eq")
        --         return false
        --     -- if type(other) == "string" then
        --     --     -- remember, the instance has __tostring above.
        --     --     return self:tostring() == other
        --     --     end
        --     --
        --     -- if other.__name == "TSNodeInstance" then
        --     --     return self:tostring() == other:tostring()
        --     -- end
        --     --
        --     -- return false
        -- end,
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

function TSNodeWrapper:replace(replacement)
    local a, b, c, d = self:range()
    vim.api.nvim_buf_set_text(
        self.buf_handle,
        a,
        b,
        c,
        d,
        type(replacement) == "string" and { replacement } or replacement
    )
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
function TSNodeWrapper:remove()
    print("TSNodeWrapper:remove()")
    -- print("self ->", self.buf_handle, self, self:range(), vim.inspect(self))
    local a, b, c, d = self:range()
    -- wierd: here, unpacking the {range()} throws err, but not above in :replace()
    vim.api.nvim_buf_set_text(self.buf_handle, a, b, c, d, {})
end

-- function TSNodeWrapper:remove()
--   error("remove() not implemented for this node type: " .. self.node:type())
-- end

function TSNodeWrapper:is_followed_by(check)
    local ns = self:next_sibling()
    if ns then
        return ns:type() == check
    end
    return false
end

function TSNodeWrapper:is_followed_by_any_of(check) end

return M
