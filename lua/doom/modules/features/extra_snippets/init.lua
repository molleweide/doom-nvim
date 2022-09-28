local uut = require("user.utils")
local extra_snippets = {}

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

return extra_snippets
