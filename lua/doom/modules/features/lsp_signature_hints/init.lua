local lsp_signatures = {}

lsp_signatures.settings = {
  bind = true,
  doc_lines = 10,
  floating_window = false, -- show hint in a floating window, set to false for virtual text only mode
  floating_window_above_cur_line = true,
  fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
  hint_enable = true, -- virtual hint enable
  hint_prefix = " ",
  hint_scheme = "String",
  hi_parameter = "Search", -- how your parameter will be highlight
  max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
  max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
  transparency = 80,
  extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  zindex = 200, -- by default it will be on top of all floating windows, set to 50 send it to bottom
  debug = false, -- set to true to enable debug logging
  padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
  shadow_blend = 36, -- if you using shadow as border use this set the opacity
  shadow_guibg = "Black", -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
}

lsp_signatures.packages = {
  ["lsp_signature.nvim"] = {
    "ray-x/lsp_signature.nvim",
    commit = "1979f1118e2b38084e7c148f279eed6e9300a342",
    -- after = "nvim-lspconfig",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    event = "VeryLazy",
  },
}

lsp_signatures.configs = {}
lsp_signatures.configs["lsp_signature.nvim"] = function()
  -- Signature help
  require("lsp_signature").setup(
    vim.tbl_deep_extend("force", doom.features.lsp_signature_hints.settings, {
      handler_opts = {
        border = doom.settings.border_style,
      },
    })
  )
end

return lsp_signatures
