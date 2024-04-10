local themes = {}

themes.settings = {}

themes.packages = {
  ["nvim-transparent"] = { "xiyaowong/nvim-transparent" },
}

themes.configs = {}

themes.configs["nvim-transparent"] = function()
  require("transparent").setup({ -- Optional, you don't have to run setup.
    groups = { -- table: default groups
      "Normal",
      "NormalNC",
      "Comment",
      "Constant",
      "Special",
      "Identifier",
      "Statement",
      "PreProc",
      "Type",
      "Underlined",
      "Todo",
      "String",
      "Function",
      "Conditional",
      "Repeat",
      "Operator",
      "Structure",
      "LineNr",
      "NonText",
      "SignColumn",
      "CursorLine",
      "CursorLineNr",
      "StatusLine",
      "StatusLineNC",
      "EndOfBuffer",
    },
    extra_groups = {}, -- table: additional groups that should be cleared
    exclude_groups = {}, -- table: groups you don't want to clear
  })

  -- You can execute this statement anywhere and as many times as you want, without worrying about whether the plugin has already been loaded or not.
  vim.g.transparent_groups = vim.list_extend(vim.g.transparent_groups or {}, { "ExtraGroup" })

  -- -- bufferline example
  -- vim.g.transparent_groups = vim.list_extend(
  --   vim.g.transparent_groups or {},
  --   vim.tbl_map(function(v)
  --     return v.hl_group
  --   end, vim.tbl_values(require("bufferline.config").highlights))
  -- )

  -- Some plugins define highlights dynamically, especially the highlights of
  -- icons. e.g. BufferLineDevIcon*, lualine_*_DevIcon*.
  --
  -- So, this plugin provide a helper function clear_prefix. It will clear all
  -- highlight groups starting with the prefix.
  --
  -- For some plugins of ui, you would like to clear all highlights. At this
  -- point you should use clear_prefix.
  -- eg.:
  -- require('transparent').clear_prefix('BufferLine')
  -- require('transparent').clear_prefix('NeoTree')
  -- require('transparent').clear_prefix('lualine')
end

return themes
