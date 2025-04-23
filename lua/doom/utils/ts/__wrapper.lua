--
-- WRAPPER CLASS
--

local M = {}
M.TSNodeWrapper = { __name = "TSNodeWrapperClass" }

function M.make_wrapped_node(self, node)
    if type(node.type) ~= "function" then
        return
    end

    local tslua = self.__tslua or self
    -- local is_first_call = rawget(self, "__tslua") == nil
    -- local tslua = is_first_call and self or rawget(self, "__tslua")
    if not tslua then
        error("No TSLua instance found for wrapped object")
    end

    -- local wrapper = tslua.subclasses[node:type()] or {}
    -- wrapper.__index = wrapper
    -- setmetatable(wrapper, {
    --     __index = setmetatable(M.TSNodeWrapper, {
    --         __index = tslua,
    --     }),
    -- })

    local wrapper = tslua.subclasses[node:type()]
    if wrapper then
        wrapper.__name = "wrapper:" .. node:type()
    else
        wrapper = {}
        wrapper.__name = string.format("wrapper:%s (undefined)", node:type())
    end
    -- Set up wrapper inheritance
    wrapper.__index = wrapper
    -- BaseWrapper → tslua fallback
    setmetatable(wrapper, {
        __index = setmetatable(M.TSNodeWrapper, {
            __index = tslua,
        }),
    })

    local instance = setmetatable({ _name = "TSNodeInstance", __tslua = tslua,  node = node }, wrapper)

    -- Make instance callable
    local mt = getmetatable(instance)
    mt.__call = M.make_wrapped_node

    return instance
end

--
-- -- Callable wrapper function
-- local function make_wrapped_node(self, node)
--     if type(node.type) ~= "function" then
--         return
--     end
--     local is_first_call = rawget(self, "__tslua") == nil
--     local tslua = is_first_call and self or rawget(self, "__tslua")
--
--     if not tslua then
--         error("No TSLua instance found for wrapped object")
--     end
--
--     -- get wrapper
--
--     local wrapper = tslua.subclasses[node:type()]
--     if wrapper then
--         wrapper.__name = "wrapper:" .. node:type()
--     else
--         wrapper = {}
--         wrapper.__name = string.format("wrapper:%s (undefined)", node:type())
--     end
--     -- Set up wrapper inheritance
--     wrapper.__index = wrapper
--     -- BaseWrapper → tslua fallback
--     setmetatable(wrapper, {
--         __index = setmetatable(BaseWrapper, {
--             __index = tslua,
--         }),
--     })
--
--     -- new instance
--
--     -- TODO: rename [node] to [node_handle] so that I can use the [node] keyword
--     local instance = setmetatable({
--         __name = "ts_proxy:" .. node:type(),
--         __tslua = tslua,
--         node = node,
--     }, wrapper)
--     -- this
--     -- if rawget(instance, "__tslua") == nil then
--     --     rawset(instance, "__tslua", tslua) -- give direct access to tslua without recurse through metatables...
--     -- end
--
--     -- Make the wrapped instance itself callable
--     local mt = getmetatable(instance)
--     mt.__call = make_wrapped_node
--
--     -- TODO: Use the below instead as __index for the instance
--
--     -- local instance = { node = node, __tslua = tslua }
--     -- -- Use a function for __index to dynamically fallback to TSNode
--     -- setmetatable(instance, {
--     --     __index = function(tbl, key)
--     --         local val
--     --         -- Prevent working on out-of-sync nodes.
--     --         if tbl.__tslua:is_out_of_sync() then
--     --             error("This node is outdated. Buffer has changed.")
--     --         end
--     --         -- 1. Look in wrapper
--     --         val = wrapper[key]
--     --         if val ~= nil then
--     --             return val
--     --         end
--     --         -- 2. Look in TSLua/base methods
--     --         val = tslua[key]
--     --         if val ~= nil then
--     --             return val
--     --         end
--     --         -- 3. Finally, fallback to TSNode methods
--     --         local node_obj = rawget(tbl, "node")
--     --         if node_obj and type(node_obj[key]) == "function" then
--     --             return function(_, ...)
--     --                 return node_obj[key](node_obj, ...)
--     --             end
--     --         end
--     --     end,
--     --     -- Make instance callable
--     --     __call = make_wrapped_node,
--     -- })
--
--     -- print(vim.inspect(instance))
--     return instance
-- end
--

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
