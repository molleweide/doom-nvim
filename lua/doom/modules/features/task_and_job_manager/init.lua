local M = {}

-- Overseer tutorial:
--    https://github.com/stevearc/overseer.nvim/blob/master/doc/tutorials.md

M.packages = {
    ["overseer.nvim"] = {
        "stevearc/overseer.nvim",
        opts = {},
    },
}

M.configs = {}

M.configs["overseer.nvim"] = function()
    require("overseer").setup()
end

return M
