local superman = {}

superman.settings = {}

-- https://github.com/lucc/nvimpager
-- https://github.com/paretje/nvim-man
-- https://github.com/vim-utils/vim-man

superman.packages = {
  ["vim-superman"] = {
    "jez/vim-superman",
    -- commit = "19d307446576d9118625c5d9d3c7a4c9bec5571a",
    cmd = "SuperMan",
    lazy = true,
  },
}

superman.configs = {}

return superman
