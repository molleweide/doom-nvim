local exemplum = {}

-- TODO:
--
--    -

----------------------------
-- SETTINGS
----------------------------

-- exemplum.settings = {}

----------------------------
-- PACKAGES
----------------------------

exemplum.packages = {
  ["exemplum.nvim"] = {
    "NTBBloodbath/exemplum.nvim",
    dependencies = { "NTBBloodbath/logging.nvim" },
  },
}

----------------------------
-- CONFIGS
----------------------------

----------------------------
-- CMDS
----------------------------

-- exemplum.cmds = {}

--------------------------
-- AUTOCMDS
--------------------------

-- exemplum.autocmds = {}

----------------------------
-- BINDS
----------------------------

-- exemplum.binds = {}

----------------------------
-- LEADER BINDS
----------------------------

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(exemplum.binds, {
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

return exemplum

