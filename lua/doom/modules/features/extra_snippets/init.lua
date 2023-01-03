local uut = require("user.utils")
local extra_snippets = {}

-- https://github.com/utilyre/spoon.nvim/tree/main/lua/spoon
-- https://github.com/madskjeldgaard/cheeky-snippets.nvim

-- NOTE: three reload locations for snippets
--
--    1. config with packer compile
--    2. plugin internal reload
--    3. rerun setup on user snippet files changed

-- TODO: picker for creating/editing snippet files

extra_snippets.settings = {
  -- doom_snippet_paths = { "doom/snippets", "user/snippets" },
  luasnip_snippets = {
    paths = { "doom/snippets", "user/snippets" },
    use_default_path = true,
    use_personal = true,
    use_internal = true, -- load snippets provided by `luasnip_snippets`
    -- ft_use_only = { "*" }, -- which filetypes do I want to have load
    -- ft_filter = { "python" },
  }
}

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

extra_snippets.configs["Luasnip-snippets.nvim"] = function()
  require("luasnip_snippets").setup(doom.modules.features.extra_snippets.settings.luasnip_snippets)
end

-- NOTE: currently this reloads via the doom reloader command

-- 							*file-pattern*
-- The pattern is interpreted like mostly used in file names:
-- 	*	matches any sequence of characters; Unusual: includes path
-- 		separators
-- 	?	matches any single character
-- 	\?	matches a '?'
-- 	.	matches a '.'
-- 	~	matches a '~'
-- 	,	separates patterns
-- 	\,	matches a ','
-- 	{ }	like \( \) in a |pattern|
-- 	,	inside { }: like \| in a |pattern|
-- 	\}	literal }
-- 	\{	literal {
-- 	\\\{n,m\}  like \{n,m} in a |pattern|
-- 	\	special meaning like in a |pattern|
-- 	[ch]	matches 'c' or 'h'
-- 	[^ch]   match any character but 'c' and 'h'

extra_snippets.autocmds = {
  {
    "BufWritePost",
    "*/doom/snippets/**/*.lua, */user/snippets/**/*.lua",
    function()
      -- BUG: why doesn't this print
      print("::: reload snips :::")
      -- require("plenary.reload").reload_module("luasnip_snippets")
    end,
  },
}

extra_snippets.binds = {
  {
    doom.settings.mappings.luasnip.next_choice,
    "<Plug>luasnip-next-choice",
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
  -- TODO: picker crud binds
}

return extra_snippets
