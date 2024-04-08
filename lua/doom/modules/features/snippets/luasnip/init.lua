local luasnip = {}

luasnip.settings = {
  luasnip = {
    config = {
      history = true,
      store_meta_data = true,
      updateevents = "TextChanged,TextChangedI",
    },
    snippets_load_dirs = {
      "./lua/doom/snips/luasnippets",
      "./lua/user/snips/luasnippets",
    },
  },
}

luasnip.packages = {
  ["LuaSnip"] = {
    "L3MON4D3/LuaSnip",
    -- commit = "53e812a6f51c9d567c98215733100f0169bcc20a",
    dev = false,
  },
}

return luasnip
