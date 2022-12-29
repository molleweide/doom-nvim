local nvim_dev = {}

-- ONLY SHOW THE LIST OF LOADED MODULES
-- :lua print(vim.inspect(package.loaded, { depth = 1 }))
--
-- make a command that allows for filtering the above by name
-- so that I can eg list all modules including `cmp` keyword
--
--  maybe this could even become a picker??

-- LONG DISCUSSION ON HOW TO RELOAD MODULES ON NEOVIM DISCOURSE
--  - https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/11
--  - https://www.lua.org/pil/8.1.html

-- todo: I need a function to

nvim_dev.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      "<leader>",
      name = "+prefix",
      {
        { "x", "<cmd>w<CR><cmd>source %<CR>", name = "Source and run current file"}
      }
    }
  },
}

return nvim_dev
