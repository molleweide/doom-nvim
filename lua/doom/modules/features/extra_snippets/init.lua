local log = require("doom.utils.logging")
local uut = require("user.utils")
local extra_snippets = {}

-- https://github.com/utilyre/spoon.nvim/tree/main/lua/spoon
-- https://github.com/madskjeldgaard/cheeky-snippets.nvim

-- NOTE: three reload locations for snippets
--
--    1. config with packer compile
--    2. plugin internal reload
--    3. rerun setup on user snippet files changed

-- TODO: fix reloader so that it reloads all snippets from scratch...

local pp = "doom.modules.features.extra_snippets.pickers"

-- TODO: reload snippets by id so that it reloads faster.
extra_snippets.reload_all_snippets = function()
  log.info("Reloading all snippets..")
  require("plenary.reload").reload_module("luasnip")
  require("plenary.reload").reload_module("luasnip_snippets")
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip_snippets").setup(doom.modules.features.extra_snippets.settings.luasnip_snippets)
end

extra_snippets.settings = {
  -- doom_snippet_paths = { "doom/snippets", "user/snippets" },
  watch_dirs = {
    "*/lua/snippets/*.lua", -- default dir
    "*/lua/user/snippets/*.lua",
    "*/lua/doom/snippets/*.lua",
  },
  luasnip_snippets = {
    prepend_new_snippets = true, -- add first/last in snip table..
    paths = { --
      "user/snippets", -- first index path is used when adding new snips
      "doom/snippets",
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
  -- extra_snippets.reload_all_snippets()
end

-- vim.cmd [[ Telescope luasnip ]]
extra_snippets.configs["telescope-luasnip.nvim"] = function()
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.load_extension("luasnip")
  end
end

extra_snippets.autocmds = {
  {
    "BufWritePost",
    -- todo: move to settigs and use table.concat here.
    -- "*/lua/doom/snippets/*.lua",
    -- "*/lua/snippets/*.lua,*/lua/user/snippets/*.lua,*/lua/doom/snippets/*.lua", -- */user/snippets/**/*.lua",
    table.concat(extra_snippets.settings.watch_dirs, ","),
    function()
      extra_snippets.reload_all_snippets()
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
