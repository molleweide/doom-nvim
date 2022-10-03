local litee = {}

litee.requires_modules = { "molleweide.lib.litee" }

litee.settings = {}

litee.packages = {
  ["litee-calltree.nvim"] = { "ldelossa/litee-calltree.nvim" },
}

litee.configs = {}

litee.configs["litee-calltree.nvim"] = function()
  require("litee.calltree").setup({})
end

return litee
