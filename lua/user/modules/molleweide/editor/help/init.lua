local help = {}

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

return help
