local indentlines = {}

indentlines.settings = {
  enabled = true,
  debounce = 300,
  -- viewport_buffer = ??,
  indent = {
    highlight = {
      "CursorColumn",
      "Whitespace",
      --
      -- "RainbowRed",
      -- "RainbowYellow",
      -- "RainbowBlue",
      -- "RainbowOrange",
      -- "RainbowGreen",
      -- "RainbowViolet",
      -- "RainbowCyan",
    },
    char = "│",
  },
  -- whitespace = {
  --   highlight = { "Function", "Label" },
  --   -- remove_blankline_trail = true,
  -- },
  -- scope = { enabled = true }, -- requires treesitter
  scope = {
    enabled = true,
    show_start = true,
    show_end = false,
    injected_languages = false,
    highlight = { "Function", "Label" },
    priority = 500,
  },

  exclude = {
    filetypes = { "help", "dashboard", "packer", "norg", "DoomInfo" },
    buftypes = { "terminal" },
  },
}

indentlines.packages = {
  ["indent-blankline.nvim"] = {
    "lukas-reineke/indent-blankline.nvim",
    -- commit = "c4c203c3e8a595bc333abaf168fcb10c13ed5fb7",
    event = "ColorScheme",
    -- main = "ibl",
  },
}

indentlines.configs = {}
indentlines.configs["indent-blankline.nvim"] = function()
  -- vim.tbl_deep_extend(
  --   "force",
  --   doom.modules.features.indentlines.settings.indent.highlight,
  --   highlight
  -- )

  -- local hooks = require("ibl.hooks")
  -- -- create the highlight groups in the highlight setup hook, so they are reset
  -- -- every time the colorscheme changes
  -- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  --   vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
  --   vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
  --   vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
  --   vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
  --   vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  --   vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
  --   vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
  -- end)

  require("ibl").setup(doom.modules.features.indentlines.settings)
  -- require("ibl").setup(
  --   vim.tbl_deep_extend("force", doom.features.indentlines.settings, {
  --     -- To remove indent lines, remove the module. Having the module and
  --     -- disabling it makes no sense.
  --     enabled = true,
  --   })
  -- )
end

return indentlines
