-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- TODO:
-- First one creates the TS object with buf, and then you wrap a table with
-- local TSBuf = TS(buf)
-- --------
-- Pass node to TS and return helper for that specific type.
-- local TSTable = TSBuf(table_constructor)
-- local TSFunction = TSBuf(function_object)
-- local TSConditional = TSBuf(conditional)

-- NOTE:
--
-- TS
--  Base class that takes buf.
--
--  TS(buf, lang)
--
-- TSLua
--      base class with all funcs that just needs access to a buffer.
--      ? Maybe we should add a query to the object so that you can reparse the
--      tree on each replacement??
--
-- TSLuaTable
--      Helper for managing and transforming tables.
--
-- TSLuaFunction
--      Helper for managing function, args, etc.
--
-- TSLuaConditional

-- -- Metatable for the Path constructor
-- Path_mt = {
--   __call = function(tbl, path_string)
--     local new_path = {
--       path = path_string,
--       -- Add any other properties or methods you need for a Path object
--     }
--     setmetatable(new_path, { __index = Path })
--     return new_path
--   end
-- }

--
-- TSBase
--

local mt = {}
local ts = {
    -- NOTE: This func should actually go into the base TS class, since it is
    -- about general nodes, rather than language specific.
    --
    ---Problem pattern: if you intend to remove a node and it is a leaf node of eg.
    ---a table or tree, then opt-in remove all ancestors until we reach an ancestry
    ---level where there are multiple leaves, or until reaches X or any of XYZ type nodes.
    ---so that we can basically remove [leaf + branch segment] if condition is met.
    ---and determine the lengh of the branch to remove based on setting/cb func.
    delete_node_until_ancestor = function(self, node) end,
}
local TSBase = setmetatable(ts, mt)

--
-- TSLua
--

---Load ts helper with buf so that you dont have to pass it later.
---local ts = TSHelper(buf)
local TSLua = setmetatable({

    buf = function(self)
        return self.buf
    end,

    -- should [filetype/lang = lua] be a class attr?
    --
    ---Currently: Returns the first node of query capture
    query = function(self, query_str)
        local parser = vim.treesitter.get_parser(self.buf, "lua", {})
        local root = parser:parse()[1]:root()
        local return_query = vim.treesitter.query.parse("lua", query_str)
        local ts_tbl
        for _, capture_node, _ in return_query:iter_captures(root, self.buf) do
            ts_tbl = capture_node:named_child():named_child()
        end
        return ts_tbl
    end,

    -- replace node text/contents
    replace = function(self, node, replacement)
        -- local start_col, end_col = module_line:find("%-%-%s") -- find first comment prefix
        local range = node:range()
        vim.api.nvim_buf_set_text(
            self.buf,
            range[1],
            range[2],
            range[3],
            range[4],
            type(replacement) == "string" and { replacement } or replacement
        )
    end,

    -- get node text
    text = function(self, node)
        return vim.treesitter.get_node_text(node, self.buf)
    end,

    content_match = function(self, node, pattern)
        return vim.treesitter.get_node_text(node, self.buf):match(pattern)
    end,

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
}, {
    __call = function(self, buf_handle)
        return setmetatable({ buf = buf_handle }, {
            __index = self,

            -- TODO: when calling TS() with a ts node, return wrapped object with helpers.
            -- __call = function
        })
    end,
})

--
-- TSLuaTable
--

-- Should inherit all of the TSHelper methods.
local TSLuaTable = setmetatable({
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

    -- :iter
    fields = function(self, opts)
        local index = 0

        -- WARN: if both index and key

        local function debug(...)
            if opts.debug then
                print(...)
            end
        end

        for child_node in self.ts_table_constructor:iter_children() do
            -- handle indexed fields

            -- if opts.index == true or type(index) == "number" or opts.type == "comment"

            if self:_field_indexed(child_node) then
                if opts.comment and child_node:type() == "comment" then
                    opts.on_comment(self.buf, child_node, index, child_node:named_child())
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
                                opts.on_index.action(self.buf, ts_string, ts_string_content)
                            end
                            -- if do each indexed string
                            if not (opts.on_index.equals or opts.on_index.match) then
                                opts.on_index.action(self.buf, ts_string, ts_string_content)
                            end

                            -- if (all or type table)
                        elseif _type == "table" and self:_field_table(child_node) then
                            local table_constructor = child_node:named_child()
                            opts.on_index.action(self.buf, table_constructor)
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
                        local text = self:text(key_identifier)
                        local match = opts.on_key[3] and text:match(opts.on_key[1])
                            or text == opts.on_key[1]
                        if match then
                            opts.on_key[2](self.buf, key_identifier, value)
                        end
                    else
                        -- do each named key
                        opts.on_key(self.buf, key_identifier, value)
                    end
                end
            end
        end
    end,

    -- each of these should take similar options...

    -- TODO:
    -- pos = first / last / after Nth node / after Nth indexed / after Nth key
    add = function() end,

    -- TODO:
    -- should handle [until] option so we can bubble up to eg first sibling
    remove = function() end,

    sort = function() end,

    -- :insert()
    tbl_add_field_last = function(self, opts) end,

    -- :remove

    -- :sort
}, {

    __index = TSLua, -- Make TSLuaTable fallback to TSLua

    __call = function(self, buf_handle, ts_table_constructor)
        return setmetatable(
            { buf = buf_handle, ts_table_constructor = ts_table_constructor },
            { __index = self }
        )
    end,
})

return {
    TSBase = TSBase,
    TSLua = TSLua,
    TSLuaTable = TSLuaTable,
}
