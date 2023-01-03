local uut = require("user.utils")
local extra_snippets = {}

-- https://github.com/utilyre/spoon.nvim/tree/main/lua/spoon
-- https://github.com/madskjeldgaard/cheeky-snippets.nvim

-- NOTE: three reload locations for snippets
--
--    1. config with packer compile
--    2. plugin internal reload
--    3. rerun setup on user snippet files changed

local pp = "doom.modules.features.extra_snippets.pickers"

extra_snippets.settings = {
  -- doom_snippet_paths = { "doom/snippets", "user/snippets" },
  luasnip_snippets = {
    paths = { --
      "doom/snippets",
      "user/snippets",
    },
    use_default_path = true,
    use_personal = true,
    use_internal = true, -- load snippets provided by `luasnip_snippets`
    -- ft_use_only = { "*" }, -- which filetypes do I want to have load
    -- ft_filter = { "python" },
  },
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
  ["telescope-luasnip.nvim"] = { "benfowler/telescope-luasnip.nvim" },
}

extra_snippets.requires_modules = { "features.lsp" }
extra_snippets.configs = {}
extra_snippets.configs["friendly-snippets"] = function()
  require("luasnip.loaders.from_vscode").lazy_load()
end

extra_snippets.configs["Luasnip-snippets.nvim"] = function()
  -- require("luasnip.loaders.from_lua").load({ paths = "./lua/doom/snippets/" })
  require("luasnip_snippets").setup(doom.modules.features.extra_snippets.settings.luasnip_snippets)
end

-- vim.cmd [[ Telescope luasnip ]]
extra_snippets.configs["telescope-luasnip.nvim"] = function()
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.load_extension("luasnip")
  end
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
    "*/snippets/**/*.lua", -- */user/snippets/**/*.lua",
    function()
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
  {
    "<leader>",
    name = "+prefix",
    {

      {
        "f",
        name = "+file",
        {
          {
            "i",
            function()
              require("telescope").extensions.luasnip.luasnip()
            end,
            name = "Snippets picker",
          },
          {
            "I",
            function()
              require(pp).luasnip_fn({
                picker_to_use = "all_available",
              })
            end,
            name = "Snippets picker (custom)",
          },
          {
            "U",
            function()
              require(pp).luasnip_fn({
                picker_to_use = "filetype",
              })
            end,
            name = "Snippets picker -> filetype (custom)",
          },
          {
            "L",
            function()
              require(pp).luasnip_fn({
                picker_to_use = "personal_snippets",
              })
            end,
            name = "Snippets picker -> personal (custom)",
          },
          {
            "E",
            function()
              -- NOTE: this opens the `lua.json` under friendly snippets
              require("luasnip.loaders").edit_snippet_files()
            end,
            name = "LuaSnip edit snippet files",
          },
        },
      },
    },
  },
}

return extra_snippets
