local editorconfig = {}

-- Depending on which version of Vim or Neovim you are using, you might not need to specifically install this plugin at all:
--
-- Vim 9.0.1799 and above comes bundled with a recent stable version of this plugin.
-- Neovim 0.9 and above comes with its own Lua-based implementation.

editorconfig.settings = {}

editorconfig.packages = {
  ["editorconfig-vim"] = {
    "editorconfig/editorconfig-vim",
    -- commit = "30ddc057f71287c3ac2beca876e7ae6d5abe26a0",
  },
}

editorconfig.configs = {}

return editorconfig
