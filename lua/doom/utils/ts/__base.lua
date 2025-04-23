local TSBase = { __name = "ts_base" }
TSBase.__index = TSBase

function TSBase:base_dummy_method()
    print("hello from ts_base. bufhandle =", self.buf_handle)
end

return TSBase
