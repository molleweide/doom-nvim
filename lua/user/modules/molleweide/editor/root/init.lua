local root = {}

--
-- MODULE FOR MANAGING CURRENT WORKING DIR
--

-- TODO: read -> `https://www.reddit.com/r/neovim/comments/zy5s0l/you_dont_need_vimrooter_usually_or_how_to_set_up/`

-- TODO: add command switch previous repo.
--
--  - nvim-rooter > to toggle dir / file dir
--  - if projects.nvim -> cmd to switch root
--
--  look at vsedovs conf for inspiration.
--
--  https://github.com/josephsdavid/neovim2
-- local clever_tcd = function()
--     local root = require('lspconfig').util.root_pattern('Project.toml', '.git')(vim.api.nvim_buf_get_name(0))
--     if root == nil then
--         root = " %:p:h"
--     end
--     vim.cmd("tcd " .. root)
--     vim.cmd("pwd")
-- end
--
--
--

root.packages = {
  ["vim-rooter"] = { "airblade/vim-rooter" },
  -- { 'oberblastmeister/nvim-rooter' },
  -- https://github.com/tzachar/cmp-fuzzy-path
}

-- root.binds = {}

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(windows.binds, {
--     "<leader>",
--     name = "+prefix",
--     {
--       {
--         "P",
--         name = "+path",
--         { -- https://stackoverflow.com/questions/38081927/vim-cding-to-git-root
--           -- - file path to global
--           -- - file git root global nvim
--           -- - active file buffer
--           -- https://stackoverflow.com/questions/38081927/vim-cding-to-git-root
--           {
--             "n",
--             "<leader>fpa",
--             "<cmd>cd %:p:h<CR><cmd>pwd<CR>",
--             options = { silent = true },
--             "Editor",
--             "cwd_to_active_file",
--             ":cd active file",
--           },
--           {
--             "n",
--             "<leader>fpg",
--             "<cmd>cd %:h | cd `git rev-parse --show-toplevel`<CR><cmd>pwd<CR>",
--             options = { silent = true },
--             "Editor",
--             "cwd_to_current_git_root",
--             ":cd active git root",
--           },
--           -- {
--           -- 	"n",
--           -- 	"<leader>fpa",
--           -- 	"<cmd>cd %:p:h<CR><cmd>pwd<CR>",
--           -- 	options = { silent = true },
--           -- 	"Editor",
--           -- 	"cwd_to_active_file",
--           -- 	":cd active file",
--           -- },
--           -- {
--           -- 	"n",
--           -- 	"<leader>fpg",
--           -- 	"<cmd>cd %:h | cd `git rev-parse --show-toplevel`<CR><cmd>pwd<CR>",
--           -- 	options = { silent = true },
--           -- 	"Editor",
--           -- 	"cwd_to_current_git_root",
--           -- 	":cd active git root",
--           -- },
--         },
--       },
--     },
--   })
-- end

return root
