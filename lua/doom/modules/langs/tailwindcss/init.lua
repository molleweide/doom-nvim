local tailwindcss = {}

-- :TailwindFoldDisable
-- :TailwindFoldEnable
-- :TailwindFoldToggle

tailwindcss.settings = {
  --- Disables auto installing the treesitter
  --- @type boolean
  disable_treesitter = false,
  --- Treesitter grammars to install
  --- @type string|string[]
  treesitter_grammars = { "css", "html", "vue" },

  --- Disables default LSP config
  --- @type boolean
  disable_lsp = false,
  --- Name of the language server
  --- @type string
  lsp_name = "tailwindcss",
  --- Custom config to pass to nvim-lspconfig
  --- @type table|nil
  lsp_config = nil,

  --- Disables null-ls formatting sources
  --- @type boolean
  disable_formatting = false,
  --- Mason.nvim package to auto install the formatter from
  --- @type string
  formatting_package = "rustywind",
  --- String to access the null_ls diagnositcs provider
  --- @type string
  formatting_provider = "builtins.formatting.rustywind",
  --- Function to configure null-ls formatter
  --- @type function|nil
  formatting_config = nil,
}

tailwindcss.packages = {
  -- https://github.com/laytan/tailwind-sorter.nvim
  -- https://github.com/princejoogie/tailwind-highlight.nvim
  -- https://github.com/js-everts/cmp-tailwind-colors
  -- https://github.com/themaxmarchuk/tailwindcss-colors.nvim
  -- https://github.com/roobert/tailwindcss-colorizer-cmp.nvim
  ["tailwind-tools.nvim"] = { "luckasRanarison/tailwind-tools.nvim" },
  ["tailiscope.nvim"] = { "danielvolchek/tailiscope.nvim" },
  -- ["tailwind-fold.nvim"] = {
  --   "razak17/tailwind-fold.nvim", -- conceal class lists that are very long.
  -- },
}

tailwindcss.configs = {}

tailwindcss.configs[""] = function()
  require("tailwind-tools").setup({
    document_color = {
      enabled = true, -- can be toggled by commands
      kind = "inline", -- "inline" | "foreground" | "background"
      inline_symbol = "󰝤 ", -- only used in inline mode
      debounce = 200, -- in milliseconds, only applied in insert mode
    },
    conceal = {
      enabled = false, -- can be toggled by commands
      min_length = nil, -- only conceal classes exceeding the provided length
      symbol = "󱏿", -- only a single character is allowed
      highlight = { -- extmark highlight options, see :h 'highlight'
        fg = "#38BDF8",
      },
    },
    custom_filetypes = {}, -- see the extension section to learn how it works
  })
end

tailwindcss.configs["tailwind-fold.nvim"] = function()
  require("tailwind-fold").setup({
    enabled = true,
    min_chars = 20, -- Only fold when class string char count is more than 30. Folds everything by default.
    ft = {
      "html",
      "svelte",
      "astro",
      "vue",
      "tsx",
      "php",
      "blade",
    },
  })
end

tailwindcss.configs["tailiscope.nvim"] = function()
  doom.features.telescope.settings.extensions["tailiscope"] = {
    -- register to copy classes to on selection
    register = "a",
    -- indicates what picker opens when running Telescope tailiscope
    -- can be any file inside of docs dir but most useful opts are
    -- all, base, categories, classes
    -- These are also accesible by running Telescope tailiscope <picker>
    default = "base",
    -- icon indicates an item which can be opened in tailwind docs
    -- can be icon or false
    doc_icon = " ",
    -- if you would prefer to copy with/without class selector
    -- dot is maintained in display to differentiate class from other pickers
    no_dot = true,
    maps = {
      i = {
        back = "<C-h>",
        open_doc = "<C-o>",
      },
      n = {
        back = "b",
        open_doc = "od",
      },
    },
  }
end

local langs_utils = require("doom.modules.langs.utils")
tailwindcss.autocmds = {
  {
    "FileType",
    "javascript,typescript,javascriptreact,typescriptreact,css,html,vue,svelte",
    langs_utils.wrap_language_setup("tailwindcss", function()
      if not tailwindcss.settings.disable_lsp then
        langs_utils.use_lsp_mason(tailwindcss.settings.lsp_name, {
          config = tailwindcss.settings.lsp_config,
        })
      end

      if not tailwindcss.settings.disable_treesitter then
        langs_utils.use_tree_sitter(tailwindcss.settings.treesitter_grammars)
      end

      if not tailwindcss.settings.disable_formatting then
        langs_utils.use_null_ls(
          tailwindcss.settings.formatting_package,
          tailwindcss.settings.formatting_provider,
          tailwindcss.settings.formatting_config
        )
      end
    end),
    once = true,
  },
}

tailwindcss.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "c",
      name = "+code",
      {
        {
          "T",
          [[<cmd>Telescope tailiscope<CR>]],
          name = "Tailwind search",
        },
      },
    },
  },
}

return tailwindcss
