local traverser = require("doom.services.traverser")

-- TODO: move this file to doom/modules/utils.lua

-- move everything from dui/modules to here??

--
-- This file hosts some common recurring traversers in doom.
--

local M = {}

-- NOTE: The traverser function is designed so that you define how to loop
-- each branch AND you also traverse into each leaf, check if it is a leaf, and
-- then call the traverse_out func.

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
                traverse_out()              -- Travel back up when a sub table has been completed.
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
            traverse_out()              -- Travel back up when a sub table has been completed.
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
