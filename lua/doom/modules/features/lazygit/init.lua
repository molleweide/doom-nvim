local lazygit = {}

-- todo: make transparent

lazygit.settings = {}

lazygit.packages = {
  ["lazygit.nvim"] = {
    "kdheepak/lazygit.nvim",
    commit = "32bffdebe273e571588f25c8a708ca7297928617",
    cmd = { "LazyGit", "LazyGitConfig" },
    lazy = true,
  },
}

lazygit.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "o",
      name = "+open/close",
      {
        { "l", "<cmd>LazyGit<CR>", name = "Lazygit" },
      },
    },
    {
      "g",
      name = "+git",
      {
        { "l", "<cmd>LazyGit<CR>", name = "Open Lazygit" },
      },
    },
  },
}

return lazygit
