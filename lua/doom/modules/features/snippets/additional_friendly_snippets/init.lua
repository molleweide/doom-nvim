local fs = {}

fs.packages = {
  ["friendly-snippets"] = {
    "rafamadriz/friendly-snippets",
    event = "VeryLazy",
  },
}

fs.configs = {
  ["friendly-snippets"] = function()
    local luasnip_exists, luasnip = pcall(require, "luasnip")
    if luasnip_exists then
      require("luasnip.loaders.from_vscode").lazy_load()
    end
  end,
}

return fs
