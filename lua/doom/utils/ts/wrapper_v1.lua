TSLua = {
  subclasses = {},
}
TSLua.__index = TSLua

-- Base wrapper shared by all subclasses
local BaseWrapper = {}

function BaseWrapper:get_node()
  return self.node
end

function BaseWrapper:get_buf()
  return self.__tslua and self.__tslua.buf_handle
end

-- Callable wrapper function
local function make_wrapped_node(self, node)
  -- Check for valid TS node
  if type(node) ~= "table" or type(node.type) ~= "function" then
    return nil
  end

  local is_first_call = self.buf_handle ~= nil
  local tslua = is_first_call and self or rawget(self, "__tslua")

  if not tslua then
    error("No TSLua instance found for wrapped object")
  end

  local wrapper = tslua.subclasses[node:type()]
  if not wrapper then return end

  -- Set up wrapper inheritance
  wrapper.__index = wrapper

  -- BaseWrapper → tslua fallback
  setmetatable(wrapper, {
    __index = setmetatable(BaseWrapper, {
      __index = tslua,
    }),
  })

  -- Create new instance with wrapper
  local instance = setmetatable({ node = node }, wrapper)

  -- Preserve reference to original TSLua instance
  if rawget(instance, "__tslua") == nil then
    rawset(instance, "__tslua", tslua)
  end

  -- Make the wrapped instance itself callable
  local mt = getmetatable(instance)
  mt.__call = make_wrapped_node

  return instance
end

function TSLua:new(buf)
  local obj = setmetatable({ buf_handle = buf }, self)

  -- Make instance callable (wraps nodes)
  return setmetatable(obj, {
    __index = self,
    __call = make_wrapped_node,
  })
end

-- Allow TSLua() to be called as constructor
setmetatable(TSLua, TSLua)
