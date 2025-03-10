local nu = {}

nu.settings = {
  --- Disables auto installing the treesitter
  --- @type boolean
  disable_treesitter = false,
  --- Treesitter grammars to install
  --- @type string|string[]
  treesitter_grammars = "nu",

  --- Disables null-ls formatting sources
  --- @type boolean
  disable_formatting = false,
  --- WARN: No package yet.  Mason.nvim package to auto install the formatter from
  --- @type nil
  formatting_package = nil,
  --- String to access the null_ls diagnositcs provider
  --- @type string
  formatting_provider = "builtins.formatting.fish_indent",
  --- Function to configure null-ls formatter
  --- @type function|nil
  formatting_config = nil,

  --- Disables null-ls diagnostic sources
  --- @type boolean
  disable_diagnostics = false,
  --- Mason.nvim package to auto install the diagnostics provider from
  --- @type nil
  diagnostics_package = nil,
  --- String to access the null_ls diagnositcs provider
  --- @type string
  diagnostics_provider = "builtins.diagnostics.nu",
  --- Function to configure null-ls diagnostics
  --- @type function|nil
  diagnostics_config = nil,
}

local langs_utils = require("doom.modules.langs.utils")
nu.autocmds = {
  {
    "FileType",
    "nu",
    langs_utils.wrap_language_setup("nu", function()
      if not nu.settings.disable_treesitter then
        langs_utils.use_tree_sitter(nu.settings.treesitter_grammars)
      end

      if not nu.settings.disable_formatting then
        langs_utils.use_null_ls(
          nu.settings.formatting_package,
          nu.settings.formatting_provider,
          nu.settings.formatting_config
        )
      end
      if not nu.settings.disable_diagnostics then
        langs_utils.use_null_ls(
          nu.settings.diagnostics_package,
          nu.settings.diagnostics_provider,
          nu.settings.diagnostics_config
        )
      end
    end),
    once = true,
  },
}

return nu

