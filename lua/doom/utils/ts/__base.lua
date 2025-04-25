local TSNodeWrapper = require("doom.utils.ts.__wrapper")

--
-- TS BUF CLASS
--
-- This class should contain shared based methods across all langs.
-- It can use the buf_handle, because it is always used as parent to the
-- TS<lang> class, BUT
--

-- -- TODO:
-- -- ~ Add flag/index check that first ensures that the buf has not been refreshed
-- --      since the instance was created. So that we can throw an error to user/dev
-- --      if we are trying to operate on a node that is out of sync.

local TSBufWrapper = {
    __name = "TSBufWrapperClass",
    -- instantiate an empty mt so that it can be easilly overridden later
    subclasses = setmetatable({}, { __index = function() end }),
}

TSBufWrapper.__index = TSBufWrapper

-------------------------------------------------------------------------------

--
-- TS BUF CLASS: METHODS
--
-- Here resides methods that have no dependencies, or optionally one dependency,
-- namely the [buf_handle].
-- Any methods that depend on the [node_handle] as well should reside in the
-- TSNodeWrapper class.
--

function TSBufWrapper:base_dummy_method()
    print("hello from ts_buf. buf_handle =", self.buf_handle)
end

function TSBufWrapper:new(buf)
    local obj = setmetatable({ buf_handle = buf }, self)
    return setmetatable(obj, {
        __index = self,
        __call = TSNodeWrapper.make_wrapped_node,
    })
end

function TSBufWrapper:buf()
    return self.buf_handle
end



return TSBufWrapper
