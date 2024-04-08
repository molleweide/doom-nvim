local user_utils = require("user.utils")

local M = {}

-- This file only hosts personal telescope pickers.
--
-- If they're more general they can be moved into `features.telescope.pickers`

M.requires_modules = { "features.telescope" }

function M.edit_xdg_configs()
  print("telescope: find xdg configs")
end

function M.edit_dotfiles_dorothy() end

function M.edit_dorothy_master() end

function M.edit_reaper_rk() end

function M.edit_surfingkeys() end

function M.find_nvim_source()
  require("telescope.builtin").find_files {
    prompt_title = "~ nvim ~",
    shorten_path = false,
    cwd = "~/build/neovim/",

    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.35,
    },
  }
end
-- SEARCH MY OWN GITHUB PROJECTS

-- TODO: move to features.telescope.pickers
function M.project_search()
  require("telescope.builtin").find_files({
    previewer = false,
    layout_strategy = "vertical",
    cwd = require("nvim_lsp.util").root_pattern(".git")(vim.fn.expand("%:p")),
  })
end

-- TODO: only search repo dirs, ie. select repo dirs, to find files within.
function M.my_ghq_user()
  require("telescope.builtin").find_files({
    cwd = user_utils.paths.ghq.molleweide,
    -- cwd = "~/plugins/",
  })
end

M.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "z",
        name = "+test",
        {
          {
            "x",
            M.edit_xdg_configs(),
            name = "find xdg configs",
          },
        },
      },
    },
  },
}

return M
