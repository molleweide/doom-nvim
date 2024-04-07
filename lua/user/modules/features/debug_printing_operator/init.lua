local printer = {}

printer.packages = {

  ["nvim-printer"] = { "fedeizzo/nvim-printer" },
}

-- printer.configs = {}
-- printer.configs["nvim-printer"] = function()
--   require("printer").setup({
--     keymap = "gp", -- Plugin doesn't have any keymaps by default
--     behavior = "insert_below", -- how operator should behave
--     -- "insert_below" will insert the text below the cursor
--     --  "yank" will not insert but instead put text into the default '"' register
--     formatters = {
--       -- you can define your formatters for specific filetypes
--       -- by assigning function that takes two strings
--       -- one text modified by 'add_to_inside' function
--       -- second the variable (thing) you want to print out
--       -- see examples in lua/formatters.lua
--       lua = function(inside, variable)
--         return string.format('print("%s: " .. %s)', inside, variable)
--       end,
--     },
--     -- function which modifies the text inside string in the print statement, by default it adds the path and line number
--     add_to_inside = function(text)
--       return string.format("[%s:%s] %s", vim.fn.expand("%"), vim.fn.line("."), text)
--     end,
--     -- to turn off default behaviour and add nothing
--     -- add_to_inside = function(text)
--     --     return text
--     -- end,
--   })
--   -- keymap to always yank the debug print
--   vim.keymap.set("n", "gp", "<Plug>(printer_yank)")
--   vim.keymap.set("v", "gp", "<Plug>(printer_yank)")
--   -- keymap to always insert below the debug print
--   vim.keymap.set("n", "gp", "<Plug>(printer_below)")
--   vim.keymap.set("v", "gp", "<Plug>(printer_below)")
--   -- You can use use '<Plug>printer_print' to call the pluging inside more advanced keymaps
--   -- for example a keymap that always adds a prnt statement based on 'iw'
--   vim.keymap.set("n", "gP", "<Plug>(printer_print)iw")
-- end

return printer
