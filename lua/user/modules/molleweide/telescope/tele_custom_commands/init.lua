local user_utils = require "user.utils"

M = {}

function M.edit_xdg()
end

function M.edit_dotfiles()
end

function M.edit_dorothy()
end

function M.edit_reaper_rk()
end

function M.edit_surfingkeys()
end

-- SEARCH MY OWN GITHUB PROJECTS

function M.project_search()
  require("telescope.builtin").find_files {
    previewer = false,
    layout_strategy = "vertical",
    cwd = require("nvim_lsp.util").root_pattern ".git"(vim.fn.expand "%:p"),
  }
end
function M.my_ghq_user()
  require("telescope.builtin").find_files {
    cwd = user_utils.paths.ghq.molleweide,
    -- cwd = "~/plugins/",
  }
end


M.cmds

return M
