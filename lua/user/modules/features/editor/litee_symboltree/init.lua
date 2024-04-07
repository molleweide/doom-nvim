local litee = {}

litee.requires_modules = { "molleweide.lib.litee" }

litee.settings = {}

litee.packages = {
  ["litee-symboltree.nvim"] = { "ldelossa/litee-symboltree.nvim" },
}

litee.configs = {}

litee.configs["litee-symboltree.nvim"] = function()
  require("litee.symboltree").setup({})
end

return litee
