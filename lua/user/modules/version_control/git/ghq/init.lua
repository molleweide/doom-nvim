local utils = require("doom.utils")
local is_module_enabled = utils.is_module_enabled
local user_util = require("user.utils")

after_telescope = user_util.after_telescope
load_extension_helper = user_util.load_extension_helper

local ghq = {}

-- TODO: make a fast telescope find on the `ghq` dir

ghq.settings = {}

ghq.packages = {
  ["telescope-ghq.nvim"] = { "nvim-telescope/telescope-ghq.nvim", after = { "telescope.nvim" } },
}

-- for _, ext in ipairs(ghq.packages) do
--   ext["after"] = after_telescope
-- end

ghq.configs = {}
ghq.configs["telescope-github.nvim"] = function()
  require("telescope").load_extension("repo")
end

-- TODO: picker -> search doom under ghq
--   Just create a basic picker for all directories under ghq that contain
--   a git file -> on enter find_files for selected directory

ghq.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "<leader>",
        name = "+prefix",
        {
          {
            "f",
            name = "+my_find",
            {
              {
                "g",
                [[<cmd>Telescope ghq list<CR>]],
                -- function()
                --   require("telescope.builtin").find_files({
                --     cwd = "~/code/repos/github.com",
                --   })
                -- end,
                name = "xdg_configs",
              },
            },
          },
        },
      },
    },
  },
}

return ghq
