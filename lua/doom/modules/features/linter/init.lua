local linter = {}

linter.settings = {
  format_on_save = false,
  null_ls_settings = {
    default_timeout = 2000,
    diagnostics_format = "#{m} (#{s})",
  },
}

linter.requires_modules = { "features.lsp" }

linter.packages = {
  -- Null-ls.nvim Reloaded, maintained by the community.
  -- Only the repo name is changed for compatibility concerns. All the API and future changes will keep in place as-is.
  ["none-ls.nvim"] = {
    "nvimtools/none-ls.nvim",
    -- commit = "915558963709ea17c5aa246ca1c9786bfee6ddb4",
    dependencies = { "neovim/nvim-lspconfig" },
    lazy = true,
  },
}

linter.configs = {}
linter.configs["none-ls.nvim"] = function()
  local null_ls = require("null-ls")

  local null_ls_settings = doom.features.linter.settings.null_ls_settings
  null_ls.setup(vim.tbl_deep_extend("force", null_ls_settings, {
    on_attach = function(client)
      if
        client.server_capabilities.documentFormattingProvider
        and doom.features.linter.settings.format_on_save
      then
        vim.cmd([[
        augroup LspFormatting
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua type(vim.lsp.buf.format) == "function" and vim.lsp.buf.format() or vim.lsp.buf.formatting_sync()
        augroup END
        ]])
      end
    end,
  }))
end

linter.binds = {
  {
    "<leader>cf",
    function()
      local null_ls_settings = doom.features.linter.settings.null_ls_settings
      if type(vim.lsp.buf.format) == "function" then
        vim.lsp.buf.format({
          timeout_ms = null_ls_settings.default_timeout,
        })
      else
        vim.lsp.buf.formatting_sync(nil, null_ls_settings.default_timeout)
      end
    end,
    name = "Format/Fix",
  },
}

return linter
