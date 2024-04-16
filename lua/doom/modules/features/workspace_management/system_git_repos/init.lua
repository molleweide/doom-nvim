local git_repos_system = {}

git_repos_system.settings = {}

git_repos_system.packages = {
  ["telescope-repo.nvim"] = { "cljoly/telescope-repo.nvim" },
  -- after = { "telescope.nvim" },
  -- dev = true
}

git_repos_system.configs = {}

git_repos_system.configs["telescope-repo.nvim"] = function()
  -- require("xx").setup(doom.modules.xx)
  table.insert(doom.features.telescope.settings.extensions, "repo")
end

-- git_repos_system.cmds = {}

-- git_repos_system.autocmds = {}

git_repos_system.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "s",
      name = "+search",
      {
        { "g", [[<cmd>Telescope repo cached_list<CR>]], name = "repos cached" },
        { "G", [[<cmd>Telescope repo list<CR>]],        name = "repos build" },
      },
    },
  },
}

return git_repos_system
