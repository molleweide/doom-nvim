-- local Wrapper = require("doom.utils.ts.__wrapper")

-- This class should contain shared based methods across all langs.
-- It can use the buf_handle, because it is always used as parent to the
-- TS<lang> class, BUT
local TSBuf = { __name = "ts_buf" }
TSBuf.__index = TSBuf

function TSBuf:base_dummy_method()
    print("hello from ts_buf. buf_handle =", self.buf_handle)
end

return TSBuf




-- -- TODO:
-- -- ~ Add flag/index check that first ensures that the buf has not been refreshed
-- --      since the instance was created. So that we can throw an error to user/dev
-- --      if we are trying to operate on a node that is out of sync.
--
-- local TSBuf = {
--     subclasses = {},
-- }
-- TSBuf.__index = TSBuf
--
-- function TSBuf:new(buf)
--     local obj = setmetatable({ buf_handle = buf }, self)
--     return setmetatable(obj, {
--         __index = self,
--         __call = Wrapper.make_wrapped_node,
--     })
-- end
--
-- return TSBuf
--
