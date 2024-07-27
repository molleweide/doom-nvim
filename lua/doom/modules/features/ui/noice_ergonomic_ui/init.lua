local noice = {}

-- TODO: wiki recipes -> https://github.com/folke/noice.nvim/wiki/Configuration-Recipes

noice.settings = {
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true,         -- use a classic bottom cmdline for search
    command_palette = false,      -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,       -- add a border to hover docs and signature help
  },
  views = {
    cmdline_popup = {
      position = {
        row = "40%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
    popupmenu = {
      -- relative = "editor",
      position = {
        row = "55%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
  },
}

noice.packages = {
  ["noice.nvim"] = {
    "folke/noice.nvim",
    requires = { "rcarriga/nvim-notify" },
  },
}

noice.configs = {}
noice.configs["noice.nvim"] = function()
  -- require("noice").setup()
  require("noice").setup(doom.modules.features.ui.noice_ergonomic_ui.settings)
end

local function toggle_noice()
  local noice = require("noice")
  local Config = require("noice.config")
  if Config.is_running() then
    noice.disable()
  else
    noice.enable()
  end
end

noice.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "t",
      name = "+tweak",
      {
        {
          "N",
          function()
            toggle_noice()
          end,
          name = "Toggle [noice]",
        },
      },
    },
  },
}

return noice
