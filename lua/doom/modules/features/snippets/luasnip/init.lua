local luasnip = {}

luasnip.settings = {
  config = {
    history = true,
    store_meta_data = true,
    updateevents = "TextChanged,TextChangedI",
  },
  snippets_load_dirs = {
    "./lua/doom/snips/luasnippets",
    "./lua/user/snips/luasnippets",
  },
}

luasnip.packages = {
  ["LuaSnip"] = {
    "L3MON4D3/LuaSnip",
    -- commit = "53e812a6f51c9d567c98215733100f0169bcc20a",
    dev = false,
  },
}

luasnip.configs = {
  ["LuaSnip"] = function()
    local ls = require("luasnip")
    ls.config.set_config(doom.features.snippets.luasnip.settings.config)
    require("luasnip.loaders.from_lua").load({
      paths = doom.modules.features.snippets.luasnip.settings.snippets_load_dirs,
    })
  end,
}

-- TODO: vim.keymap.set("i", "<c-u>", require "luasnip.extras.select_choice")

local function next_choice()
  local ls = require("luasnip")
  if ls.choice_active() then
    vim.cmd([[<Plug>luasnip-next-choice]])
  end
end

local function prev_choice()
  local ls = require("luasnip")
  if ls.choice_active() then
    vim.cmd([[<Plug>luasnip-prev-choice]])
  end
end

luasnip.binds = {

  {
    doom.settings.mappings.luasnip.next_choice,
    next_choice,
    name = "Luasnip next choice",
    mode = "i",
  },
  {
    doom.settings.mappings.luasnip.next_choice,
    "<Plug>luasnip-next-choice",
    name = "Luasnip next choice s",
    mode = "s",
  },
  {
    doom.settings.mappings.luasnip.prev_choice,
    "<Plug>luasnip-prev-choice",
    name = "Luasnip prev choice",
    mode = "i",
  },
  {
    doom.settings.mappings.luasnip.prev_choice,
    "<Plug>luasnip-prev-choice",
    name = "Luasnip prev choice s",
    mode = "s",
  },
}

return luasnip
