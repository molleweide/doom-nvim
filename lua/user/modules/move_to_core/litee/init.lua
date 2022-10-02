local litee = {}

litee.settings = {}

litee.packages = {
  ["litee.nvim"] = {
    "ldelossa/litee.nvim",
    -- opt = "true",
  },
}

litee.config = {}

litee.config["litee.nvim"] = function()
  require("litee.lib").setup({
    tree = {
      icon_set = "codicons",
    },
    panel = {
      orientation = "right",
      panel_size = 30,
    },
  })
end

return litee
