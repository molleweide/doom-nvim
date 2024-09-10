local care = {}

-- TODO:
--    - Ensure that care/cmp are mutually exclusive??

----------------------------
-- SETTINGS
----------------------------

-- care.settings = {}

----------------------------
-- PACKAGES
----------------------------

care.packages = {
    ["care.nvim"] = {
        "max397574/care.nvim",
        dev = true,
        -- dependencies = { -- if not using rocks
        --     {
        --         "romgrk/fzy-lua-native",
        --         build = "make", -- optional, uses faster native version
        --     },
        -- },
    },
}

----------------------------
-- CONFIGS
----------------------------

-- care.configs = {}
-- care.configs["care.nvim"] = function()
--     local labels = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
--     -- Add this to formatting
--     -- { {
--     --     " " .. require("care.presets.utils").LabelEntries(labels)(entry, data) .. " ",
--     --     "Comment",
--     -- }, },
--     -- Keymappings
--     for i, label in ipairs(labels) do
--         vim.keymap.set("i", "<c-" .. label .. ">", function()
--             require("care").api.select_visible(i)
--             -- If you also want to confirm the entry
--             require("care").api.confirm()
--         end)
--     end
-- end

----------------------------
-- CMDS
----------------------------

-- care.cmds = {}

--------------------------
-- AUTOCMDS
--------------------------

-- care.autocmds = {}

----------------------------
-- BINDS
----------------------------

-- TODO: Use treesitter to move the mode field to the last position in each
-- table.

care.binds = {
    {
        mode = { "i" },
        "<c-n>",
        function()
            vim.snippet.jump(1)
        end,
    },
    {
        mode = { "i" },
        "<c-p>",
        function()
            vim.snippet.jump(-1)
        end,
    },
    {
        mode = { "i" },
        "<c-space>",
        function()
            require("care").api.complete()
        end,
    },
    { mode = { "i" }, "<cr>", "<Plug>(CareConfirm)" },
    { mode = { "i" }, "<c-e>", "<Plug>(CareClose)" },
    { mode = { "i" }, "<tab>", "<Plug>(CareSelectNext)" },
    { mode = { "i" }, "<s-tab>", "<Plug>(CareSelectPrev)" },
    {
        mode = { "i" },
        "<c-f>",
        function()
            if require("care").api.doc_is_open() then
                require("care").api.scroll_docs(4)
            else
                vim.api.nvim_feedkeys(vim.keycode("<c-f>"), "n", false)
            end
        end,
    },
    {
        mode = { "i" },
        "<c-d>",
        function()
            if require("care").api.doc_is_open() then
                require("care").api.scroll_docs(-4)
            else
                vim.api.nvim_feedkeys(vim.keycode("<c-f>"), "n", false)
            end
        end,
    },
}

return care
