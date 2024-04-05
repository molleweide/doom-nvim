local tsctx = {}

-- tsctx.settings = {
--   context_header = {
--     enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--     max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
--     min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
--     line_numbers = true,
--     multiline_threshold = 20, -- Maximum number of lines to show for a single context
--     trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
--     mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
--     -- Separator between context and content. Should be a single character string, like '-'.
--     -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
--     separator = nil,
--     zindex = 20, -- The Z-index of the context window
--     on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
--   },
--   context_inline = {
--     -- Enable by default. You can disable and use :NvimContextVtToggle to maually enable.
--     -- Default: true
--     enabled = true,
--
--     -- Override default virtual text prefix
--     -- Default: '-->'
--     prefix = "",
--
--     -- Override the internal highlight group name
--     -- Default: 'ContextVt'
--     highlight = "CustomContextVt",
--
--     -- Disable virtual text for given filetypes
--     -- Default: { 'markdown' }
--     disable_ft = { "markdown" },
--
--     -- Disable display of virtual text below blocks for indentation based languages like Python
--     -- Default: false
--     disable_virtual_lines = false,
--
--     -- Same as above but only for spesific filetypes
--     -- Default: {}
--     disable_virtual_lines_ft = { "yaml" },
--
--     -- How many lines required after starting position to show virtual text
--     -- Default: 1 (equals two lines total)
--     min_rows = 1,
--
--     -- Same as above but only for spesific filetypes
--     -- Default: {}
--     min_rows_ft = {},
--
--     -- Custom virtual text node parser callback
--     -- Default: nil
--     custom_parser = function(node, ft, opts)
--       local utils = require("nvim_context_vt.utils")
--
--       -- If you return `nil`, no virtual text will be displayed.
--       if node:type() == "function" then
--         return nil
--       end
--
--       -- This is the standard text
--       return opts.prefix .. " " .. utils.get_node_text(node)[1]
--     end,
--
--     -- Custom node validator callback
--     -- Default: nil
--     custom_validator = function(node, ft, opts)
--       -- Internally a node is matched against min_rows and configured targets
--       local default_validator = require("nvim_context_vt.utils").default_validator
--       if default_validator(node, ft) then
--         -- Custom behaviour after using the internal validator
--         if node:type() == "function" then
--           return false
--         end
--       end
--
--       return true
--     end,
--
--     -- Custom node virtual text resolver callback
--     -- Default: nil
--     custom_resolver = function(nodes, ft, opts)
--       -- By default the last node is used
--       return nodes[#nodes]
--     end,
--   },
-- }

tsctx.packages = {
  ["nvim-treesitter-context"] = { "nvim-treesitter/nvim-treesitter-context" },
  ["nvim_context_vt"] = { "haringsrob/nvim_context_vt" },
}

tsctx.configs = {}

tsctx.configs["nvim-treesitter-context"] = function()
  require("treesitter-context").setup({
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  })
end

tsctx.configs["nvim_context_vt"] = function()
  require("nvim_context_vt").setup({
    -- Enable by default. You can disable and use :NvimContextVtToggle to maually enable.
    -- Default: true
    enabled = true,

    -- Override default virtual text prefix
    -- Default: '-->'
    prefix = "",

    -- Override the internal highlight group name
    -- Default: 'ContextVt'
    highlight = "ContextVt", -- CustomContextVt

    -- Disable virtual text for given filetypes
    -- Default: { 'markdown' }
    disable_ft = { "markdown" },

    -- Disable display of virtual text below blocks for indentation based languages like Python
    -- Default: false
    disable_virtual_lines = false,

    -- Same as above but only for spesific filetypes
    -- Default: {}
    disable_virtual_lines_ft = {},  -- eg. "yaml"

    -- How many lines required after starting position to show virtual text
    -- Default: 1 (equals two lines total)
    min_rows = 1,

    -- Same as above but only for spesific filetypes
    -- Default: {}
    min_rows_ft = {},

    -- Custom virtual text node parser callback
    -- Default: nil
    -- custom_parser = function(node, ft, opts)
    --   local utils = require("nvim_context_vt.utils")
    --
    --   -- If you return `nil`, no virtual text will be displayed.
    --   if node:type() == "function" then
    --     return nil
    --   end
    --
    --   -- This is the standard text
    --   return opts.prefix .. " " .. utils.get_node_text(node)[1]
    -- end,

    -- Custom node validator callback
    -- Default: nil
    -- custom_validator = function(node, ft, opts)
    --   -- Internally a node is matched against min_rows and configured targets
    --   local default_validator = require("nvim_context_vt.utils").default_validator
    --   if default_validator(node, ft) then
    --     -- Custom behaviour after using the internal validator
    --     if node:type() == "function" then
    --       return false
    --     end
    --   end
    --
    --   return true
    -- end,

    -- Custom node virtual text resolver callback
    -- Default: nil
    -- custom_resolver = function(nodes, ft, opts)
    --   -- By default the last node is used
    --   return nodes[#nodes]
    -- end,
  })
end

tsctx.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "n",
      name = "+test",
      {
        {
          {
            "t",
            name = "+ts",
            { "c", [[ :TSContextToggle<cr> ]], name = "toggle context" },
            { "v", [[ :NvimContextVtToggle<cr> ]], name = "toggle vt context" },
            { "V", [[ :NvimContextVtDebug<cr> ]], name = "vt ctx debug" },
          },
        },
      },
    },
  },
}

return tsctx
