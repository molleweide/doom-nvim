local nvim_dev = {}

nvim_dev.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      "<leader>",
      name = "+prefix",
      {
        { "x", "<cmd>w<CR><cmd>source %<CR>", name = "Save and source"}
      }
    }
  },
}

return nvim_dev
