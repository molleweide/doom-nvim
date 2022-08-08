local lazygit = {}

-- todo: make transparent

lazygit.settings = {}

lazygit.packages = {
  ["lazygit.nvim"] = {
    "kdheepak/lazygit.nvim",
    commit = "9c73fd69a4c1cb3b3fc35b741ac968e331642600",
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
