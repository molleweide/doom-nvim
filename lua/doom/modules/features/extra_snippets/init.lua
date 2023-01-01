local uut = require("user.utils")
local extra_snippets = {}

-- https://github.com/utilyre/spoon.nvim/tree/main/lua/spoon
-- https://github.com/madskjeldgaard/cheeky-snippets.nvim

extra_snippets.settings = {}

extra_snippets.packages = {
  ["friendly-snippets"] = {
    "rafamadriz/friendly-snippets",
    after = "LuaSnip",
  },
  ["Luasnip-snippets.nvim"] = {
    uut.paths.ghq.github .. "molleweide/LuaSnip-snippets.nvim",
    after = "LuaSnip",
  },
}

extra_snippets.requires_modules = { "features.lsp" }
extra_snippets.configs = {}
extra_snippets.configs["friendly-snippets"] = function()
  require("luasnip.loaders.from_vscode").lazy_load()
end

-- TODO: MOVE SNIPPETS PATH TO SETTINGS.
extra_snippets.configs["Luasnip-snippets.nvim"] = function()
  require("luasnip_snippets").setup({
    paths = { "doom/snippets", "user/snippets" },
    use = { "c" },
    use_luasnip_snippets = false, -- load snippets provided by `luasnip_snippets`
  })
end

-- The active choice for a choiceNode can be changed by calling
-- `ls.change_choice(1)` (forwards) or `ls.change_choice(-1)` (backwards), for
-- example via

extra_snippets.binds = {
  { doom.settings.mappings.luasnip.next_choice, "<Plug>luasnip-next-choice", name = "Luasnip next choice", mode = "i" },
  { doom.settings.mappings.luasnip.next_choice, "<Plug>luasnip-next-choice", name = "Luasnip next choice s", mode = "s" },
  { doom.settings.mappings.luasnip.prev_choice, "<Plug>luasnip-prev-choice", name = "Luasnip prev choice", mode = "i" },
  { doom.settings.mappings.luasnip.prev_choice, "<Plug>luasnip-prev-choice", name = "Luasnip prev choice s", mode = "s" },
}

return extra_snippets
