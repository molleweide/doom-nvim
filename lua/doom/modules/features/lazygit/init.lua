local lazygit = {}

-- todo: make transparent

lazygit.settings = {}

lazygit.packages = {
  ["lazygit.nvim"] = {
    "kdheepak/lazygit.nvim",
    commit = "1f9f372b9fc137b8123d12a78c22a26c0fa78f0a",
    cmd = { "LazyGit", "LazyGitConfig" },
    opt = true,
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
