-- ts/__base.lua
local Wrapper = require("ts.wrapper")

-- TODO:
-- ~ Add flag/index check that first ensures that the buf has not been refreshed
--      since the instance was created. So that we can throw an error to user/dev
--      if we are trying to operate on a node that is out of sync.

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

