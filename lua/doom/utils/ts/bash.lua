local TSBash = setmetatable({ __name = "TSBashClass" }, require("doom.utils.ts.__base"))
TSBash.__index = TSBash

-------------------------------------------------------------------------------
--
-- LUA NODE _type SPECIFIC SUB CLASSES
--

local subclasses = TSBash.subclasses
-- handle lookup for keyword clashes
setmetatable(subclasses, {
    __index = function(t, k)
        -- print("subclass __index key:", k)
        if k == "true" or k == "false" then
            return rawget(t, "boolean")
        end
        return rawget(t, k)
    end,
})

subclasses.function_definition = {}
subclasses.word = {}
subclasses.compound_statement = {}
subclasses.comment = {}
subclasses.command = {}
subclasses.raw_string = {}
subclasses.string = {}
subclasses.simple_expansion = {}
subclasses.special_variable_name = {}

return TSBash
