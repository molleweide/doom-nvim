-------------------------------------------------------------------------------
--
-- CLASS: NODE BASE WRAPPER
--

-- NOTE: BaseWrapper should go into __base.lua

-- Base wrapper shared by all subclasses
local BaseWrapper = { __name = "base_wrapper" }

---Check if a ts proxy is of a certain type [check_type]
---@param check_type String The type we want to compare against
function BaseWrapper:is(check_type)
    return self.node:type() == check_type
end

-- TODO: rename to node() -> returns the raw node, so that one can do iter methods.
-- Which might be a bit trickier to play nicely with the wrapper.
function BaseWrapper:get_node()
    return self.node
end

function BaseWrapper:get_text()
    return vim.treesitter.get_node_text(self.node, self.buf_handle)
end

---Make it easy to move a node to another location after/before node X.
function BaseWrapper:move_to(opts) end

---Helper that prints context about node
function BaseWrapper:print_context(opts)
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
function BaseWrapper:remove() end

-------------------------------------------------------------------------------
--
-- CLASS: TS LUA
--

---Load ts helper with buf so that you dont have to pass it later.
---local ts = TSHelper(buf)

TSLua = {
    __name = "ts_lua",
    subclasses = {},
}
TSLua.__index = TSLua

-- Callable wrapper function
local function make_wrapped_node(self, node)
    if type(node.type) ~= "function" then
        return
    end
    local is_first_call = rawget(self, "__tslua") == nil
    local tslua = is_first_call and self or rawget(self, "__tslua")

    if not tslua then
        error("No TSLua instance found for wrapped object")
    end

    -- get wrapper

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
        __index = setmetatable(BaseWrapper, {
            __index = tslua,
        }),
    })

    -- new instance

    -- TODO: rename [node] to [node_handle] so that I can use the [node] keyword
    local instance = setmetatable({
        __name = "ts_proxy:" .. node:type(),
        __tslua = tslua,
        node = node,
    }, wrapper)
    -- this
    -- if rawget(instance, "__tslua") == nil then
    --     rawset(instance, "__tslua", tslua) -- give direct access to tslua without recurse through metatables...
    -- end

    -- Make the wrapped instance itself callable
    local mt = getmetatable(instance)
    mt.__call = make_wrapped_node

    -- TODO: Use the below instead as __index for the instance

    -- local instance = { node = node, __tslua = tslua }
    -- -- Use a function for __index to dynamically fallback to TSNode
    -- setmetatable(instance, {
    --     __index = function(tbl, key)
    --         local val
    --         -- Prevent working on out-of-sync nodes.
    --         if tbl.__tslua:is_out_of_sync() then
    --             error("This node is outdated. Buffer has changed.")
    --         end
    --         -- 1. Look in wrapper
    --         val = wrapper[key]
    --         if val ~= nil then
    --             return val
    --         end
    --         -- 2. Look in TSLua/base methods
    --         val = tslua[key]
    --         if val ~= nil then
    --             return val
    --         end
    --         -- 3. Finally, fallback to TSNode methods
    --         local node_obj = rawget(tbl, "node")
    --         if node_obj and type(node_obj[key]) == "function" then
    --             return function(_, ...)
    --                 return node_obj[key](node_obj, ...)
    --             end
    --         end
    --     end,
    --     -- Make instance callable
    --     __call = make_wrapped_node,
    -- })

    print(vim.inspect(instance))
    return instance
end

-- <lang> buf class constructor.
function TSLua:new(buf)
    local obj = setmetatable({ __name = "ts_lua:instance", buf_handle = buf }, self)

    -- Make instance callable (wraps nodes)
    return setmetatable(obj, {
        __index = self,
        __call = make_wrapped_node,
    })
end

-- Allow TSLua() to be called as constructor
setmetatable(TSLua, {
    __index = require("doom.utils.ts.__base"),
})

--
-- TS LUA METHODS
--

function TSLua:new(buf)
    local obj = setmetatable({ buf_handle = buf }, self)
    local instance = setmetatable(obj, {
        __index = self,
        __call = make_wrapped_node, -- Make the instance callable (not the class)
    })
    print(vim.inspect(instance))
    return instance
end

-- get buf handle
function TSLua:buf(self)
    return self.buf_handle
end

---Currently: Returns a wrapped instance of the last captured node.
function TSLua:query_wrap(query_str)
    local parser = vim.treesitter.get_parser(self.buf_handle, "lua", {})
    local root = parser:parse()[1]:root()
    local return_query = vim.treesitter.query.parse("lua", query_str)
    local ts_tbl
    for _, capture_node, _ in return_query:iter_captures(root, self.buf_handle) do
        ts_tbl = capture_node
        print("type:", ts_tbl:type())
    end
    -- print("query_wrap self >>>>", vim.inspect(self))
    return self(ts_tbl)
end

-- replace node text/contents
function TSLua:replace(node, replacement)
    -- local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
    local range = node:range()
    vim.api.nvim_buf_set_text(
        self.buf_handle,
        range[1],
        range[2],
        range[3],
        range[4],
        type(replacement) == "string" and { replacement } or replacement
    )
end

-- get node text
function TSLua:text(node)
    -- print("XXXX", tostring(node), self.buf_handle)
    -- print(vim.inspect(self))
    return vim.treesitter.get_node_text(node, self.buf_handle)
end

function TSLua:content_match(self, node, pattern)
    return vim.treesitter.get_node_text(node, self.buf_handle):match(pattern)
end

-------------------------------------------------------------------------------
--
-- LUA NODE _type SPECIFIC SUB CLASSES
--

local subclasses = TSLua.subclasses

--
-- lua table
--

---Table
subclasses.table_constructor = {
    -- TODO: wrap in metatable and replicate regular lua table behavior.
    --
    -- loop all (pairs) | indexes (ipair) | keys (pairs and key ~= number)
    --
    -- match specific { index | value type.}
    --
    -- TSTable:fields({
    --      action = function
    -- })
    --
    -- TSTable:fields({
    --      key = 2,
    --      action = <function>
    -- },
    -- {
    --   key = <string>,
    --   action
    -- },
    -- {
    --   key = { <string>, <bool> },
    --   value = <type>,
    --   action
    -- })
    --
    --
    -- pass in an array of tables that represent actions to perform for certain
    -- index/key/value specifications.
    --
    -- NOTE: Something like this should make this flexible enough.
    -- opts = {
    --      index = bool | number | function, eg index < N
    --      key = bool | <table>{ string, is_pattern } | function
    --      value = { type = string, equals|match} -- custom
    --      action =
    --      get_replace = if you want to replace multiple fields, then get the edit object for each edit.
    -- }
    --
    -- NOTE: another brainstorm on the api
    --
    -- index/key, action
    --
    -- key, value, action
    -- _, {}, function
    --
    -- >> IF MULT ARGS
    --      index = bool | number | function, eg index < N
    --      key = { string, is_pattern }
    --      value = { type = string, equals|match}
    -- >> OR PASS TABLE
    --
    -- TSModTbl:fields({
    --     index = 1,
    --     value = { "string", ret.t_path_left[1] },
    --     action = function(buf, str, content)
    --         ret.module_table_constructor = value_table
    --         ret.module = true
    --         ret.module_real_name = ts:text(content)
    --         ret.module_name_string = str
    --         ret.module_range = { value_table:range() }
    --     end,
    -- })
    _field_indexed = function(self, node)
        return node:named() and node:named_child_count() == 1
    end,
    _field_key = function(self, node)
        return node:named() and node:named_child_count() == 2
    end,
    _field_string = function(self, node)
        return node:type() == "field" and node:named_child(0):type() == "string"
    end,
    _field_table = function(self, node)
        return node:type() == "field" and node:named_child():type() == "table_constructor"
    end,

    -- :iter
    fields = function(self, opts)
        local index = 0

        -- WARN: if both index and key

        local function debug(...)
            if opts.debug then
                print(...)
            end
        end

        for child_node in self.node:iter_children() do
            -- handle indexed fields

            -- if opts.index == true or type(index) == "number" or opts.type == "comment"

            if self:_field_indexed(child_node) then
                if opts.comment and child_node:type() == "comment" then
                    opts.on_comment(self.buf_handle, child_node, index, child_node:named_child())
                end

                -- if key == true or type(key) == "number"

                if opts.on_index then
                    index = index + 1
                    local _type = opts.on_index.type
                    local index_target = opts.on_index.index
                    local equals = opts.on_index.equals
                    local match = opts.on_index.match

                    if not index_target or (index_target and index_target == index) then
                        -- if (all or type string)
                        if _type == "string" and self:_field_string(child_node) then
                            local ts_string = child_node:named_child()
                            local ts_string_content = ts_string:named_child()
                            local text = self:text(ts_string_content)
                            -- if handle compare value
                            if equals and equals == text or match and text:match(match) then
                                opts.on_index.action(self(ts_string), self(ts_string_content))
                            end
                            -- if do each indexed string
                            if not (opts.on_index.equals or opts.on_index.match) then
                                opts.on_index.action(self(ts_string), self(ts_string_content))
                            end

                            -- if (all or type table)
                        elseif _type == "table" and self:_field_table(child_node) then
                            local table_constructor = child_node:named_child()
                            -- print("??? gettable", vim.inspect(self))
                            opts.on_index.action(self(table_constructor))
                        else
                            -- TODO: Handle all other types that can exist in a
                            -- table:
                            -- boolean, expression, function,
                        end
                    end
                end
            end
            -- handle key value pairs
            -- TODO: handle when keys are wrapped in [] and also keys that
            -- handle key value pair fields
            --
            --
            -- if key == true or type(key) == "string"
            --
            if opts.on_key then
                if self:_field_key(child_node) then
                    local key_identifier = child_node:named_child(0)
                    local value = child_node:named_child(1)

                    if type(opts.on_key) == "table" then
                        -- do only keys that match pattern regex
                        -- print("??? field.self:", vim.inspect(self))
                        -- print("getmetatable:", vim.inspect(getmetatable(self)))
                        local text = self:text(key_identifier)
                        local match = opts.on_key[3] and text:match(opts.on_key[1])
                            or text == opts.on_key[1]
                        if match then
                            print("<<< on_key >>>")
                            opts.on_key[2](self(key_identifier), self(value))
                        end
                    else
                        -- do each named key
                        opts.on_key(self.buf_handle, key_identifier, value)
                    end
                end
            end
        end
    end,

    ---Handle removal of the table itself.
    ---Figure out (with opt in capabilities) if we should bubble up to an ancestor
    ---table or what should be done depending on the context.
    remove = function(self) end,

    -- put all indexed fields / keyed fields together
    rearrange = function(self) end,

    -- sort table keys. (and put the after / before any existing indexed fields)
    sort = function() end,

    -- each of these should take similar options...

    -- TODO:
    -- pos = first / last / after Nth node / after Nth indexed / after Nth key
    -- Default -> add element new field last.
    add_field = function() end,

    -- TODO:
    -- should handle [until] option so we can bubble up to eg first sibling
    remove_field = function() end,

    -- move field to after/before indexed/keyed valued N
    move_field = function() end,

    -- :insert()
    tbl_add_field_last = function(self, opts) end,

    -- :remove

    -- :sort
}

--
-- lua boolean
--

---Booleans
subclasses.boolean = {
    toggle = function(self) end,
    set = function(self, new_value) end,
}

return TSLua
