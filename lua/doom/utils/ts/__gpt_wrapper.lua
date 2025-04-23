-- ts/wrapper.lua
local M = {}

M.BaseWrapper = {}

function M.BaseWrapper:get_node()
    return self.node
end

function M.make_wrapped_node(self, node)
    local tslua = self.__tslua or self

    if type(node.type) ~= "function" then
        return
    end

    local wrapper = tslua.subclasses[node:type()] or {}

    wrapper.__index = wrapper

    setmetatable(wrapper, {
        __index = setmetatable(M.BaseWrapper, {
            __index = tslua,
        }),
    })

    local instance = setmetatable({ node = node }, wrapper)

    -- Make instance callable
    local mt = getmetatable(instance)
    mt.__call = M.make_wrapped_node

    return instance
end

return M

