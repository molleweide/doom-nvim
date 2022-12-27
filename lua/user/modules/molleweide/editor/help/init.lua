local help = {}

-- TODO:
--
--    > lua referene toc
--    > man ...
--    > help under cursor inner word
--

help.packages = {}

-- TODO: if builtin command -> proceed to finding the command in `:Man bash` so that I actualy can find the command

help.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      "h",
      name = "+help",
      {
        { "t", [[ :lua require"telescope.builtin".help_tags<CR>]], name = "Telescope Help" },
        { "m", ":Man ", name = "Man Page" },
        {
          "l",
          ":help lua_reference_toc<CR>",
          name = "Lua Reference",
        },
        {
          "w",
          '"zyiw:h <c-r>z<cr>',
          name = "Help Inner Word",
        },
        { "H", ":help ", name = ":help" },
        {
          "c",
          "<cmd>helpc<cr>",
          name = "Close Help",
        },
      },
    },
  },
}

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(help.binds, {
--     "<leader>",
--     name = "+prefix",
--     {
--       "h",
--       name = "+help",
--       {
--         { "n", "<leader>hm", ":Man ", { silent = false }, "Man Page", "man_page", "Man Page" },
--         {
--           "n",
--           "<leader>hl",
--           ":help lua_reference_toc<CR>",
--           { silent = false },
--           "Lua Reference",
--           "lua_reference",
--           "Lua Reference",
--         },
--         {
--           "n",
--           "<leader>hw",
--           '"zyiw:h <c-r>z<cr>',
--           { silent = false },
--           "Help Inner Word",
--           "help_inner_word",
--           "Inner Word",
--         },
--         { "n", "<leader>hh", ":help ", { silent = false }, "Help", "help", "Help" },
--         {
--           "n",
--           "<leader>hc",
--           "<cmd>helpc<cr>",
--           { silent = false },
--           "Close Help",
--           "close_help",
--           "Close Help",
--         },
--       },
--     },
--   })
-- end

return help
