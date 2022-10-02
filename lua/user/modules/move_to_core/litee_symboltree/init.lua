local litee = {}

litee.requires_modules = { "move_to_core.litee" }

litee.settings = {}

litee.packages = {
  ["litee-symboltree.nvim"] = { "ldelossa/litee-symboltree.nvim" },
}

litee.config = {}

litee.config["litee-symboltree.nvim"] = function()
  require("litee.symboltree").setup({})
end

return litee
