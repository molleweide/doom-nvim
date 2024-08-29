local help = {}

-- TODO: Display nvim version corresponding to core features
--    https://github.com/tweekmonster/helpful.vim

help.binds = {
    {
        "<leader>",
        name = "+prefix",
        {
            "h",
            name = "+help",
            {
                {
                    "t",
                    function()
                        require("telescope.builtin").help_tags()
                    end,
                    name = "Telescope Help",
                },
                { "m", ":Man ", name = "Man Page", opts = { silent = false } },
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
                { "H", ":help ", name = ":help", opts = { silent = false } },
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
