local windows = {}

-- https://github.com/declancm/windex.nvim

-- TODO: left hand  `<leader>w(nav|extend)` right hand `(amounts|special)`
--
--    so that one can manage and extend windows and manage windows super fast with a set
--    of interesting functions

windows.packages = {
  ["focus.nvim"] = {
    "beauwilliams/focus.nvim",
    config = function()
      require("focus").setup()
    end,
  },
}

windows.binds = {
    "<leader>",
    name = "+prefix",
    {
      {
        "w",
        name = "+windows",
        {
          { "z", [[<esc><cmd>suspend<CR>]], name = "suspend vim" },
          -- { "S", [[<esc><CR>]], name = "solo window / close all others" }, -- nvim get windows > compare some idx/name > close match set
          -- { "move"}
          -- { "new/rm"}
        },
      },
    },
  }

return windows
