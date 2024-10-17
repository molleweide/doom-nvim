local terminal = {}

-- TODO: terminal module todos
-- ~ add telescope picker for selecting terminals
-- ~ add float terminal toggle
-- ~ terminal in nvim Tab
--
-- FIX: support / integrate dorothy properly.
-- ensure all soures are loaded properly.

---

-- local float_handler = function(term)
--   if not as.falsy(fn.mapcheck('jk', 't')) then
--     vim.keymap.del('t', 'jk', { buffer = term.bufnr })
--     vim.keymap.del('t', '<esc>', { buffer = term.bufnr })
--   end
-- end

local lazygit_term_handle

---

local float_opts = {
    height = function()
        return math.floor(vim.o.lines * 0.8)
    end,
    width = function()
        return math.floor(vim.o.columns * 0.95)
    end,
}

terminal.settings = {
    size = 10,
    open_mapping = "<F4>",
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    start_in_insert = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    float_opts = {
        border = "curved",
        width = 70,
        height = 20,
        winblend = 0,
        highlights = {
            border = "Special",
            background = "Normal",
        },
    },
}

-- https://github.com/rockerBOO/awesome-neovim#terminal-integration
--
-- https://github.com/zbirenbaum/nvim-chadterm
-- https://github.com/oberblastmeister/termwrapper.nvim
--
-- NOTE: A plugin that leverages Neovim's built-in RPC functionality to simplify
-- opening files from within Neovim's terminal emulator without nesting
-- sessions.
--   -> https://github.com/samjwill/nvim-unception

--
--
-- LoricAndre/OneTerm.nvim - Plugin framework for running commands in the terminal.
-- nikvdp/neomux - Control Neovim from shells running inside Neovim.
-- akinsho/nvim-toggleterm.lua - A Neovim Lua plugin to help easily manage multiple terminal windows.
-- norcalli/nvim-terminal.lua - A high performance filetype mode for Neovim which leverages conceal and highlights your buffer with the correct color codes.
-- numToStr/FTerm.nvim - No nonsense floating terminal written in Lua.
-- oberblastmeister/termwrapper.nvim - Wrapper for Neovim's terminal features to make them more user friendly.
-- pianocomposer321/consolation.nvim - A general-purpose terminal wrapper and management plugin for Neovim, written in Lua.
-- jghauser/kitty-runner.nvim - Poor man's REPL. Easily send buffer lines and commands to a kitty terminal.
-- jlesquembre/nterm.nvim - A Neovim plugin to interact with the terminal, with notifications.
-- s1n7ax/nvim-terminal - A simple & easy to use multi-terminal plugin.
terminal.packages = {
    ["toggleterm.nvim"] = {
        "akinsho/toggleterm.nvim",
        -- commit = "a54e6c471ce1cd8ef8357e34598a28a955297131",
        cmd = { "ToggleTerm", "TermExec" },
        lazy = true,
    },
    -- https://github.com/distek/tt.nvim
    -- https://github.com/sychen52/smart-term-esc.nvim
}

terminal.configs = {}
terminal.configs["toggleterm.nvim"] = function()
    require("toggleterm").setup(doom.features.terminal.settings)

    local Terminal = require("toggleterm.terminal").Terminal

    lazygit_term_handle = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        hidden = true,
        direction = "float",
        -- on_open = float_handler,
        float_opts = float_opts,
    })
end

-- local function toggle_term_custom()
--   if doom.settings.term_exec_cmd == "" then
--     vim.cmd("ToggleTerm")
--   else
--     local cmd = string.format("TermExec cmd=\"%s\"", doom.settings.term_exec_cmd)
--     vim.cmd(cmd)
--   end
-- end

local function toggle_lazyvim()
    if not lazygit_term_handle then
        local Terminal = require("toggleterm.terminal").Terminal
        lazygit_term_handle = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            hidden = true,
            direction = "float",
            -- on_open = float_handler,
            float_opts = float_opts,
        })
    end
    lazygit_term_handle:toggle()
end

-- " Count is 0 by default
-- command! -count -complete=shellcmd -nargs=* TermExec lua require'toggleterm'.exec_command(<q-args>, <count>)
-- command! -count -nargs=* ToggleTerm lua require'toggleterm'.toggle_command(<q-args>, <count>)
-- command! -bang ToggleTermToggleAll lua require'toggleterm'.toggle_all(<q-bang>)
terminal.binds = {
    "<leader>",
    name = "+prefix",
    {
        {
            "o",
            name = "+open/close",
            {
                "t",
                name = "+terminal",
                {
                    {
                        "w",
                        name = "Term Toggle",
                        function()
                            require("toggleterm").toggle_command(nil, 0)
                        end,
                    },
                    {
                        "m",
                        name = "Term Toggle 1",
                        function()
                            require("toggleterm").toggle_command("size=40 direction=horizontal", 1)
                        end,
                    },
                    {
                        ",",
                        name = "Term Toggle 2",
                        function()
                            require("toggleterm").toggle_command("size=40 direction=horizontal", 2)
                        end,
                    },
                    {
                        ".",
                        name = "Term Toggle 3",
                        function()
                            require("toggleterm").toggle_command("size=40 direction=vertical", 3)
                        end,
                    },
                    {
                        "a",
                        name = "Term Toggle All",
                        function()
                            require("toggleterm").toggle_all()
                        end,
                    },
                    {
                        -- FIX: reset when cwd changes,
                        "l",
                        name = "toggleterm: toggle lazygit",
                        function()
                            toggle_lazyvim()
                        end,
                    },
                    {
                        "s",
                        name = "Term Select",
                        "<cmd>TermSelect<CR>",
                    },
                    {
                        "r",
                        name = "Term Rename",
                        "<cmd>ToggleTermSetName<CR>",
                    },
                }, -- ot inner {}
            }, -- ot
        }, -- o
    },
}

return terminal
