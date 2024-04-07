local litee = {}

litee.requires_modules = { "molleweide.lib.litee" }

litee.settings = {}

litee.packages = {
  ["litee-bookmarks.nvim"] = { "ldelossa/litee-bookmarks.nvim" },
}

litee.configs = {}

litee.configs["litee-bookmarks.nvim"] = function()
  require("litee.bookmarks").setup({})
end

return litee
