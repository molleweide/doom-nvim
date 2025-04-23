-- ts/__base.lua
local Wrapper = require("ts.wrapper")

local TSBuf = {
    subclasses = {},
}
TSBuf.__index = TSBuf

function TSBuf:new(buf)
    local obj = setmetatable({ buf_handle = buf }, self)
    return setmetatable(obj, {
        __index = self,
        __call = Wrapper.make_wrapped_node,
    })
end

return TSBuf

