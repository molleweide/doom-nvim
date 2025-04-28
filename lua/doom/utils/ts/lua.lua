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
        -- print("subclass __index key:", k)
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

    -- WARN: DEPRECATED
    -- _field_indexed = function(self, node)
    --     return node:named() and node:named_child_count() == 1
    -- end,
    -- _field_key = function(self, node)
    --     return node:named() and node:named_child_count() == 2
    -- end,
    -- _field_string = function(self, node)
    --     return node:type() == "field" and node:named_child(0):type() == "string"
    -- end,
    -- _field_table = function(self, node)
    --     return node:type() == "field" and node:named_child():type() == "table_constructor"
    -- end,

    -- WARN: DEPRECATED
    -- fields = function(self, opts)
    --     local index = 0
    --     local function debug(...)
    --         if opts.debug then
    --             print(...)
    --         end
    --     end
    --     for child_node in self.node_handle:iter_children() do
    --         -- handle indexed fields
    --         -- if opts.index == true or type(index) == "number" or opts.type == "comment"
    --         if self:_field_indexed(child_node) then
    --             if opts.comment and child_node:type() == "comment" then
    --                 opts.on_comment(self.buf_handle, child_node, index, child_node:named_child())
    --             end
    --             -- if key == true or type(key) == "number"
    --             if opts.on_index then
    --                 index = index + 1
    --                 local _type = opts.on_index.type
    --                 local index_target = opts.on_index.index
    --                 local equals = opts.on_index.equals
    --                 local match = opts.on_index.match
    --                 if not index_target or (index_target and index_target == index) then
    --                     -- if (all or type string)
    --                     if _type == "string" and self:_field_string(child_node) then
    --                         local ts_string = child_node:named_child()
    --                         local ts_string_content = ts_string:named_child()
    --                         local text = self:get_text(ts_string_content)
    --                         -- if handle compare value
    --                         if equals and equals == text or match and text:match(match) then
    --                             opts.on_index.action(self(ts_string), self(ts_string_content))
    --                         end
    --                         -- if do each indexed string
    --                         if not (opts.on_index.equals or opts.on_index.match) then
    --                             opts.on_index.action(self(ts_string), self(ts_string_content))
    --                         end
    --                         -- if (all or type table)
    --                     elseif _type == "table" and self:_field_table(child_node) then
    --                         local table_constructor = child_node:named_child()
    --                         opts.on_index.action(self(table_constructor))
    --                     else
    --                         -- todo: Handle all other types that can exist in a
    --                         -- table:
    --                         -- boolean, expression, function,
    --                     end
    --                 end
    --             end
    --         end
    --         -- handle key value pairs
    --         -- todo: handle when keys are wrapped in [] and also keys that
    --         -- handle key value pair fields
    --         --
    --         --
    --         -- if key == true or type(key) == "string"
    --         --
    --         if opts.on_key then
    --             if self:_field_key(child_node) then
    --                 local key_identifier = child_node:named_child(0)
    --                 local value = child_node:named_child(1)
    --                 if type(opts.on_key) == "table" then
    --                     -- do only keys that match pattern regex
    --                     local text = self:get_text(key_identifier)
    --                     local match = opts.on_key[3] and text:match(opts.on_key[1])
    --                         or text == opts.on_key[1]
    --                     if match then
    --                         -- print("value:type():", value:type())
    --                         opts.on_key[2](self(key_identifier), self(value))
    --                     end
    --                 else
    --                     -- do each named key
    --                     opts.on_key(self(key_identifier), self(value))
    --                 end
    --             end
    --         end
    --     end
    -- end,

    -- try get indexed child node of index N
    index = function(self, i)
        -- use iter_fields under the hood
    end,

    -- try get a child node where key == string
    key = function(self, key_string)
        -- use iter_fields under the hood
    end,

    -- Example usage:
    -- for count, key, value, field in ts_tbl_in:iter_fields() do
    --     print(string.format("#%s: key(%s), value(%s), field(%s)", count, key, value, field))
    -- end
    --
    -- TODO: if filter type == ["index"|"key"]
    --      then return
    --
    ---@return table|number KeyNodeOrIndex # Either a number or node, depending on if the field is indexed or key-value pair.
    ---@return table ValueNode
    ---@return table FieldNode
    ---@return number RealIndex The real node index count number.
    iter_fields = function(self, filter_type, include_comments)
        local prev_node
        local field_index_real = 0
        local index_indexed = 0 -- count each indexed field

        local function ignore_node_type(check_node)
            if check_node:type() == "comment" and not include_comments then
                print("ignore comment")
                return true
            end
            if check_node:is_index() and filter_type == "keys" then
                return true
            end
            if check_node:is_key() and filter_type == "indexed" then
                return true
            end
        end

        local function next_sib(start_node)
            local next_node
            local found_next
            while not found_next do
                -- print(">", type(next_node), next_node)
                if not next_node then
                    next_node = self(start_node:next_named_sibling())
                else
                    next_node = self(next_node:next_named_sibling())
                end

                if next_node == nil then
                    return
                -- elseif include_comments or next_node:type() ~= "comment" then
                elseif not ignore_node_type(next_node) then
                    found_next = true -- ensure we dont include comment nodes
                end
            end
            return next_node
        end

        local first_child = self(self:named_child())
        if not first_child then
            return
        end

        -- print("first child type = ", first_child:type())

        if ignore_node_type(first_child) then
            first_child = next_sib(first_child)
        end

        if not first_child then
            return
        end

        -- if first_child:type() == "comment" then
        --     first_child = next_sib(first_child)
        -- end

        -- print(":::::::::::::::::::::::::")
        --

        print(string.format("filter_type: %s, include_comments: %s", filter_type, include_comments))

        return function()
            local next_node
            if field_index_real == 0 then
                -- print("> first...")
                next_node = self(first_child)
            else
                next_node = next_sib(prev_node)
                -- local found_next
                -- while not found_next do
                --     -- print(">", type(next_node), next_node)
                --
                --     if not next_node then
                --         next_node = self(prev_node:next_named_sibling())
                --     else
                --         next_node = self(next_node:next_named_sibling())
                --     end
                --
                --     if next_node == nil then
                --         return
                --     elseif include_comments or next_node:type() ~= "comment" then
                --         found_next = true -- ensure we dont include comment nodes
                --     end
                -- end
            end
            field_index_real = field_index_real + 1
            if not next_node then
                return
            end
            prev_node = next_node

            print("NEXT NODE:", next_node:type())

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

            -- TODO: return field_index_real last
            return the_index, the_value, next_node, field_index_real
        end
    end,

    -- NOTE: if the key in tables are [identifiers]. It doesnt care if the
    -- key is an actual string name or an identifier pointing to some other
    -- variable! name = ... or [name] = are both parsed as [identifiers]. You
    -- have to check for the contents of the node to determine if it is a pointer
    -- value or not.
    --
    ---Build a virtual dict of the table, so that I can access keys like a
    ---regular lua table.
    ---On the call, it will iterate all nodes and build the dict, then on
    ---subsequent calls, I will be able to instantly access all keys. This
    ---removes a lot of unnecessary "direct" usages of [iter_fields], since
    ---it should mostly be used in cases when you actually want to loop
    ---and operate on multiple elements. not just one...
    ---@param string|number key The key or index we want to check for.
    ---@return table WrappedNode A wrapped node of the value.
    dict = function(input_key)
        -- if first call, then build dict map
        if not self.virtual_table then
            self.virtual_table = {}
            for key, value, field, index in self:iter_fields() do
                self.virtual_table[type(key) == "number" and key or tostring(key)] = value
            end
        end

        -- TODO: maybe we should put each node in a subtable with { key, value, field }
        -- and then return everything. Since it is a minimal overhead.
        return self.virtual_table[input_key]
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
    sort = function()
        -- TODO: Use https://github.com/mtrajano/tssorter.nvim to sort this table
        -- automatically.
    end,

    -- TODO: pos = first / last / after Nth node / after Nth indexed / after Nth key
    ---Default add element new field last.
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
        -- print("ts_tbl:add_field(): data before inserting", vim.inspect(data))
        vim.api.nvim_buf_set_text(self.buf_handle, row, col, row, col, data)
    end,

    ---Remove a field from the table.
    remove_field = function(opts)
        -- TODO: iter_fields and check predicates.

        -- try using the switch pattern here?/

        if not opts then
            -- try remove last indexed node.
        end

        -- if number -> try remove indexed key
        --      if arg2 then remove node index N
        --      else remove is_index N

        -- if string -> remove by string comparison
        --      if arg2 then do pattern,
        --      else do exact match

        -- if func -> call func to determine if field should be removed

        -- if table ?? is it necessary
    end,

    ---Move field to after/before indexed/keyed valued N in self
    move_field = function() end,
}

subclasses.boolean = {
    toggle = function(self)
        if tostring(self) == "true" then
            print(string.format("hello from boolean: %s -> false", self))
            self:replace("false")
        else
            print(string.format("hello from boolean: %s -> true", self))
            self:replace("true")
        end

        -- get text
        --
        -- if true then flip
        return true
    end,

    set = function(self, new_value)
        if new_value then
            self:replace("true")
        else
            self:replace("false")
        end
        return true
    end,
}

subclasses.number = {
    increment = function(self) end,
    decrement = function(self) end,
    add = function(self) end,
    subtract = function(self) end,
    evaluate = function(self) end,
}

subclasses.string = {
    content = function(self)
        return self(self:named_child()) -- a string always has a string_content child!
    end,
}

subclasses.comment = {}
subclasses.return_statement = {}
subclasses.expression_list = {}
subclasses.assignment_statement = {}
subclasses.variable_declaration = {}
subclasses.dot_index_expression = {}
subclasses.identifier = {}
subclasses.function_call = {}
subclasses.function_declaratOn = {}
subclasses.arguments = {}

return TSLua
