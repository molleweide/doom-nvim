local log = require("doom.utils.logging")

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

local toggle_root_conditional = function()
  if doom.settings.rooter_or_project then
    vim.cmd([[Rooter]])
  else
    -- project.nvim toggle root. the command might be incorrect
    vim.cmd([[ProjRoot]])
  end
end

root.packages = {
  ["vim-rooter"] = { "airblade/vim-rooter" },
  -- { 'oberblastmeister/nvim-rooter' },
  -- https://github.com/tzachar/cmp-fuzzy-path
}

-- TODO: autocmd for setting proj root
--
--    if file is outside of $pwd then run [[Rooter]]

root.autocmds = {
  {
    "BufEnter,BufWinEnter",
    "*",
    function()
      -- log.info("Module: root -> autocmd set: project root")
      toggle_root_conditional()
    end,
  },
}

-- TODO: toggle auto set root
root.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "f",
      name = "+files",
      {
        {
          "p",
          name = "+project",
          {
            {
              "r",
              function()
                log.info("Toggle root!")
                toggle_root_conditional()
              end,
              name = "Rooter toggle",
            },
          },
        },
      },
    },
    {
      "P",
      name = "+path",
      { -- https://stackoverflow.com/questions/38081927/vim-cding-to-git-root
        -- - file path to global
        -- - file git root global nvim
        -- - active file buffer
        -- https://stackoverflow.com/questions/38081927/vim-cding-to-git-root
        {
          "a",
          "<cmd>cd %:p:h<CR><cmd>pwd<CR>",
          name = "cwd_to_active_file",
        },
        {
          "g",
          "<cmd>cd %:h | cd `git rev-parse --show-toplevel`<CR><cmd>pwd<CR>",
          name = "cwd_to_current_git_root",
        },
      },
    },
  },
}

return root
