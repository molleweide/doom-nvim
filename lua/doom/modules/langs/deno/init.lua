-- https://deno.land/manual@v1.25.0/getting_started/setup_your_environment#neovim-06-using-the-built-in-language-server
--
-- git@github.com:vim-denops/denops.vim.git
-- https://github.com/hrsh7th/deno-nvim-types

-- require("lspconfig").denols.setup({
-- 		capabilities = setup.capabilities,
-- 		-- autostart = true,
-- 		cmd = { "deno", "lsp" },
-- 		on_attach = require("lsp.lsp-attach").on_attach,
-- 		filetypes = {
-- 			"javascript",
-- 			"javascriptreact",
-- 			"javascript.jsx",
-- 			"typescript",
-- 			"typescriptreact",
-- 			"typescript.tsx",
-- 		},
-- 		init_options = {
-- 			enable = true,
-- 			lint = true,
-- 			unstable = true,
-- 		},
-- 	})
