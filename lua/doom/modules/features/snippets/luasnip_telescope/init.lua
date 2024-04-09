local pp = "doom.modules.features.snippets.luasnip_telescope.pickers"

local lst = {}

lst.packages = {
  ["telescope-luasnip.nvim"] = { "benfowler/telescope-luasnip.nvim" },
}

-- note: vim.cmd [[ Telescope luasnip ]]
lst.configs = {}
lst.configs["telescope-luasnip.nvim"] = function()
  local ok, telescope = pcall(require, "telescope")
  local ls_ok = pcall(require, "luasnip")
  if ok and ls_ok then
    telescope.load_extension("luasnip")
  end
end

-- TODO: add snippet to filetype -> open `user/snips/luasnippets/<ft>/init.lua`

lst.binds = {
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
              require(pp).snippets_picker()
            end,
            name = "Picker: available snips",
          },
          -- {
          --   "F",
          --   function()
          --     -- TODO: only pick available filetypes...
          --   end,
          --   name = "Picker: luasnip;available fts",
          -- },
          {
            "U",
            function()
              require(pp).filetype_picker()
            end,
            name = "Picker: luasnip by filetype",
          },
          {
            "L",
            function()
              require(pp).snippets_picker({
                selected_filetypes = "everything",
              })
            end,
            name = "Picker: snips -> everything",
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

return lst
