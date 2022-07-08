local rust = {}

rust.settings = {
}

-- lua.packages = {
-- https://github.com/Saecki/crates.nvim
--   ["rust-tools.nvim"] = {
--     "simrat39/rust-tools.nvim",
--     ft = "rust",
--   },
-- }


rust.autocmds = {
  {
    "BufWinEnter",
    "*.rs",
    function()
      local langs_utils = require('doom.modules.langs.utils')

      langs_utils.use_lsp('rust_analyzer')

      require("nvim-treesitter.install").ensure_installed("rust")

      -- Setup null-ls
      if doom.features.linter then
        local null_ls = require("null-ls")
        langs_utils.use_null_ls_source({
          null_ls.builtins.formatting.rustfmt
        })
      end
    end,
    once = true,
  },
}

return rust
