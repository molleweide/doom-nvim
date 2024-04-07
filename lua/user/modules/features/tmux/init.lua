local tmux = {}

-- https://github.com/yazgoo/vmux

tmux.settings = {}
-- https://github.com/hkupty/nvimux
tmux.packages = {
  ["vim-tmux-navigator"] = { "christoomey/vim-tmux-navigator" },
  ["vim-tmux-resizer"] = { "melonmanchan/vim-tmux-resizer" },
  ["vimux"] = { "benmills/vimux" },
  -- https://github.com/danielpieper/telescope-tmuxinator.nvim
}

return tmux
