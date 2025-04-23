-- ts/lua.lua
local TSBuf = require("ts.__base")

local LuaTS = setmetatable({}, TSBuf)
LuaTS.__index = LuaTS

-- Define any language-specific methods or subclasses
LuaTS.subclasses["function_definition"] = {
    my_special = function(self)
        -- ...
    end
}

return LuaTS

