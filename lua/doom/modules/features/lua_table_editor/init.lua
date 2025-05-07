local lua_table_editor = {}

-- TODO: recursively flatten the table with TS.

lua_table_editor.description = [[
Provides a [PICKER] that allows one to filter, add, and edit fields of a table.
]]

---You either 1) pass a wrapped table node, or 2) buffer and cursor position.
---If (2) then we can bubble the ancestors and run the picker on the whole
---table.
lua_table_editor.picker = function()
    -- TODO: ...
end

----------------------------
-- SETTINGS
----------------------------

-- lua_table_editor.settings = {}

----------------------------
-- PACKAGES
----------------------------

-- lua_table_editor.packages = {
-- [""] = {},
-- -- [""] = {},
-- -- [""] = {},
-- -- [""] = {},
-- }

----------------------------
-- CONFIGS
----------------------------

----------------------------
-- CMDS
----------------------------

-- lua_table_editor.cmds = {}

--------------------------
-- AUTOCMDS
--------------------------

-- lua_table_editor.autocmds = {}

----------------------------
-- BINDS
----------------------------

-- lua_table_editor.binds = {}

----------------------------
-- LEADER BINDS
----------------------------

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(lua_table_editor.binds, {
--     "<leader>",
--     name = "+prefix",
--     {
--       {
--         "YYY",
--         name = "+ZZZ",
--         {
--         -- first level
--         },
--       },
--     },
--   })
-- end

----------------------------
-- RETURN
----------------------------

return lua_table_editor
