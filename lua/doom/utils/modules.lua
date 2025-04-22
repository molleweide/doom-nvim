local system = require("doom.core.system")

local traverser = require("doom.services.traverser")

-- TODO: move this file to doom/modules/utils.lua

-- move everything from dui/modules to here??

--
-- This file hosts some common recurring traversers in doom.
--

local M = {}

local doom_config_root = require("doom.core.system").doom_configs_root

-----------------------------------------------------------------------------
-- NOTE: I could put this on the module itself so iff you M.__call to generate
-- the object.
local ModSpec = {}

M.ModSpec = ModSpec

-- ModSpec.t_path = function()
--     local t_path = { self }
--     return {
--         self[1],
--     }
-- end

ModSpec.path = function()
    return table.concat({
        doom_config_root,
        "lua",
        self.origin,
        "modules",
        table.concat(self, system.sep),
        "init.lua",
    }, system.sep)
end

local mt = {}

setmetatable(ModSpec, mt)

mt.__call = function(self, node, stack)
    -- if type node == table -> then we are working with node/stack
    -- if type == string, then we make it from a path segment.

    local o = node

    local t_section = {}

    if stack ~= nil then
        -- then, we assum that we are only being passed [origin], and [t_path]
        -- in the node table.
        -- set default enabled = true.
        -- use for each instead and exclude the module name
        for _, sn in ipairs(stack) do
            if type(sn.key) == "string" then
                table.insert(t_section, sn.key:lower())
            end
        end
        o.section = table.concat(t_section, ".")
    else
        t_section = node.t_section
        o.section = table.concat(t_section, ".")
    end

    -- TODO: Use this later if i remove dependency on path
    -- o.path_init_file = table.concat({
    --     doom_config_root,
    --     "lua",
    --     "user",
    --     "modules",
    --     table.concat(decl.t_section, "/"),
    --     node[1],
    --     "init.lua",
    -- }, system.sep)

    local Path = require("pathlib")
    local module_init_file = Path(
        doom_config_root,
        "lua",
        "user",
        "modules",
        table.concat(t_section, "/"),
        o[1],
        "init.lua"
    )

    if module_init_file:exists() then
        o.origin = "user"
        o.path_init_file = module_init_file:tostring()
    else
        local doom_path_str = module_init_file:gsub("lua/user/", "lua/doom/")
        local doom_path = Path(doom_path_str)

        if doom_path:exists() then
            o.origin = "doom"
            -- gsub returns multiple values. Path only accepts one.
            o.path_init_file = module_init_file:gsub("lua/user/", "lua/doom/")
        else
            o.missing = true
        end
    end

    -- make t_path
    table.insert(t_section, node[1])
    o.t_path = t_section

    -- print("o.t_path:", vim.inspect(o.t_path))

    return setmetatable(o, { __index = self })
end

-- :origin
-- :section
-- :name
-- :path_init
-- :path_lua
-- ModSpec.

-----------------------------------------------------------------------------

M.get_module_t_path_from_init_path = function(s)
    return vim.split(s:match("modules/(.-)/init.lua$"), "/")
end

-- NOTE: The traverser function is designed so that you define how to loop
-- each branch AND you also traverse into each leaf, check if it is a leaf, and
-- then call the traverse_out func.
--

-- Designed to travers `modules.lua` file, ie. allows you to operate on
-- each module `dot` path.
M.traverse_modules_declarations = traverser.build({
    -- Builds the traversal function defining how we should move through the tree
    -- @param node any The node itself
    -- @param next function(node: any) Traverse into the traverse_in node, adding the node to the stack
    -- @param traverse_out function() Traverses back a depth, pops the value from the stack
    -- @param err function(message: string) Traverses back a depth, this value is skipped by the handler (see below)
    traverser = function(node, stack, traverse_in, traverse_out, err)
        local parent = stack[#stack]

        local parent_is_section = (
            parent == nil or (type(parent.key) == "string" and type(parent.node) == "table")
        )

        -- todo: key == string, and node = table.
        if type(node) == "table" and parent_is_section then
            if vim.tbl_count(node) == 0 then
                traverse_out() -- Handle case if a table is empty.
            else
                for key, value in pairs(node) do
                    traverse_in(key, value) -- Traverse into next layer.
                end
                traverse_out() -- Travel back up when a sub table has been completed.
            end
        elseif type(node) == "string" and not parent_is_section then
            -- Old method for declaring enabled modules as simple strings
            traverse_out() -- This is a leaf, traverse back a layer.
        elseif parent and type(parent.key) == "number" and type(node) == "table" then
            -- New method, where module is declared as a table
            traverse_out() -- Travel back up when a sub table has been completed.
        else
            err(
                ("doom-nvim: Error traversing doom modules in `modules.lua`, unexpected value `%s`."):format(
                    vim.inspect(node)
                )
            ) -- Traverse back a layer but do not pass this value to the handler function.
        end
    end,
})

-- FIX: remove dependency on Path
M.get_module_init_path_from_module_decl = function(decl)
    local doom_config_root = require("doom.core.system").doom_configs_root
    local Path = require("pathlib")
    return Path(
        doom_config_root,
        "lua",
        "user",
        "modules",
        table.concat(decl.t_section, "/"),
        decl[1],
        "init.lua"
    )
end

-- allow pass a callback and accumulator so I can add custom actions to
-- perform on each iteration.
-- eg get the max with of all sections etc computed from the ModSpec object
M.get_modules_list_with_origins = function(enabled_modules, cb)
    local mods = {}

    require("doom.utils.modules").traverse_modules_declarations(
        enabled_modules,
        function(node, stack)
            -- TODO: pass the stack and node into

            -- log.warn(node)
            if type(node[1]) == "string" then
                local mod = ModSpec(node, stack)
                table.insert(mods, mod)
                if cb and type(cb) == "function" then
                    cb(mod)
                end
            end
        end
    )

    return mods
end

---Recurse through the tree of loaded modules, ie `doom.<path.to.some.module>`
---Allows user to perform actions based on the contents of each module.
M.traverse_loaded = traverser.build({
    traverser = function(node, stack, traverse_in, traverse_out, err)
        if node.type == "doom_module_single" then
            traverse_out()
        else
            for key, value in pairs(node) do
                traverse_in(key, value) -- Traverse into next layer.
            end
            traverse_out() -- Travel back up when a sub table has been completed.
        end
        -- else
        --   err(
        --     ("doom-nvim: Error traversing `doom.modules`, unexpected value `%s`."):format(
        --       vim.inspect(node)
        --     )
        --   ) -- Traverse back a layer but do not pass this value to the handler function.
        -- end
    end,
})

return M
