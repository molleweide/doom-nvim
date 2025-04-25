local TSLua = setmetatable({ __name = "TSLuaClass" }, require("doom.utils.ts.__base"))
TSLua.__index = TSLua

function TSLua:test(msg)
    print("test from TSLua", msg)
end

---Currently: Returns a wrapped instance of the last captured node.
function TSLua:query_wrap(query_str)
    local parser = vim.treesitter.get_parser(self.buf_handle, "lua", {})
    local root = parser:parse()[1]:root()
    local return_query = vim.treesitter.query.parse("lua", query_str)
    local ts_tbl
    for _, capture_node, _ in return_query:iter_captures(root, self.buf_handle) do
        ts_tbl = capture_node
        -- print("type:", ts_tbl:type())
    end
    -- print("query_wrap self >>>>", vim.inspect(self))
    return self(ts_tbl)
end

-------------------------------------------------------------------------------
--
-- LUA NODE _type SPECIFIC SUB CLASSES
--

local subclasses = TSLua.subclasses
-- handle lookup for keyword clashes
setmetatable(subclasses, {
    __index = function(t, k)
        print("subclass __index key:", k)
        if k == "true" or k == "false" then
            return rawget(t, "boolean")
        end
        return rawget(t, k)
    end,
})

subclasses.field = {
    field_type = function(self)
        if self:is_index() then
            return "index"
        elseif self:is_key() then
            return "key"
        end
    end,
    is_index = function(self)
        return self:named_child_count() == 1
    end,
    is_key = function(self)
        return self:named_child_count() == 2
    end,
}

subclasses.table_constructor = {

    test = function(self, msg)
        print("test from subclasses.table_constructor", msg)
    end,

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

        for child_node in self.node_handle:iter_children() do
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
                            local text = self:get_text(ts_string_content)
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
                        local text = self:get_text(key_identifier)

                        local match = opts.on_key[3] and text:match(opts.on_key[1])
                            or text == opts.on_key[1]

                        if match then
                            -- print("value:type():", value:type())
                            opts.on_key[2](self(key_identifier), self(value))
                        end
                    else
                        -- do each named key
                        opts.on_key(self(key_identifier), self(value))
                    end
                end
            end
        end
    end,

    -- Example usage:
    -- for count, key, value, field in ts_tbl_in:iter_fields() do
    --     print(string.format("#%s: key(%s), value(%s), field(%s)", count, key, value, field))
    -- end
    iter_fields = function(self)
        local first_child = self:named_child()
        if not first_child then
            return
        end
        local next_node
        local prev_node
        local index_total = 0
        local index_indexed = 0 -- count each indexed field

        return function()
            if index_total == 0 then
                next_node = self(first_child)
            else
                next_node = self(prev_node:next_named_sibling())
            end
            if not next_node then
                return
            end
            index_total = index_total + 1
            prev_node = next_node

            -- compute return values
            local the_index, the_value
            if next_node:is_index() then
                index_indexed = index_indexed + 1
                the_index = index_indexed
                the_value = self(next_node:named_child())
            else
                the_index = self(next_node:named_child(0))
                the_value = self(next_node:named_child(1))
            end
            return index_total, the_index, the_value, next_node
        end
    end,

    -- TODO:
    --      ~ remove field?
    --      ~ bubble up until sibling and remove?
    --      ~ max remove up until last ancestor.
    --
    ---Handle removal of the table itself.
    ---Figure out (with opt in capabilities) if we should bubble up to an ancestor
    ---table or what should be done depending on the context.
    ---@return
    ---     ok,
    ---     message
    remove = function(self)
        local parent_field = self(self:parent())

        -- TEST: function: remove_nodes_up_until(fn)
        -- where fn eg.:
        -- function()
        --      -- check if current is of type X
        -- end

        if parent_field:type() == "field" then
            -- wierd: here, unpacking the {range()} throws err, but not above in :replace()
            local a, b, c, d = self:range()
            vim.api.nvim_buf_set_text(
                self.buf_handle,
                a,
                b,
                c,
                d + (parent_field:is_followed_by(",") and 1 or 0),
                {}
            )
        else
            return false, string.format("Error: Removing %s will break the code!", self:type())
        end
    end,

    -- put all indexed fields / keyed fields together
    rearrange = function(self) end,

    -- sort table keys. (and put the after / before any existing indexed fields)
    sort = function() end,

    -- each of these should take similar options...

    -- pos = first / last / after Nth node / after Nth indexed / after Nth key
    -- Default -> add element new field last.
    add_field = function(self, opts)
        opts = opts or {}

        if not opts.data then
            return
        end

        local data = opts.data

        local range = { self.node_handle:range() }

        local row, col
        if not opts.pos or opts.pos == "last" then
            row, col = range[3], range[4] - 1
        elseif opts.pos == "first" then
            row, col = range[1], range[2] + 1
            data[#data] = data[#data] .. ","
        end

        print("ts_tbl:add_field(): data before inserting", vim.inspect(data))
        vim.api.nvim_buf_set_text(self.buf_handle, row, col, row, col, data)
    end,

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

subclasses.boolean = {
    toggle = function(self)
        print("hello from boolean:", self)

        -- get text
        --
        -- if true then flip
    end,

    set = function(self, new_value)
        if new_value then
        -- self:replace("true")
        else
            -- self:replace("false")
        end
    end,
}

return TSLua
