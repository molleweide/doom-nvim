local ts_architext_ui = {}

-- NOTE: treesitter/fltr || ts/architext; ts/ssr; ts/ast-grep;
-- search filter and transform text with treesitter.

-- TODO:
--
--    -  play around with the plugin and learn how it works, then make a cool ui
--    	for it that makes it look cool when you make queries.
--
--    	floating popup ui where I can use keys to jump around between these ui windows.
--    	also add mappings for moving the ui around. or repositioning the floats.
--
--    	this is stupid but it is also fun and good practice to play around with UI placement etc.
--
--    	TODO: add ability to apply architext to a file, instead of a buffer.
--
--    	TODO: highlight captures from repl query.

-- ts_architext_ui.settings = {}

-- git@github.com:cshuaimin/ssr.nvim.git
ts_architext_ui.packages = {
    ["architext.nvim"] = { "vigoux/architext.nvim", dev = true },
    -- [""] = {},
    -- [""] = {},
    -- [""] = {},
}

-- ts_architext_ui.cmds = {}

-- ts_architext_ui.autocmds = {}

-- ts_architext_ui.binds = {}

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(ts_architext_ui.binds, {
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

return ts_architext_ui
