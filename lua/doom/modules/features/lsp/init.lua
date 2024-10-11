local lsp = {}

-- TODO: Rename module to `lsp_config`

-- TODO: Create a handler that ignores global variables from your doom config

-- TODO: create function/picker to manage active lsp servers.

-- https://github.com/onsails/lspkind.nvim

lsp.settings = {
    icons = {
        error = "",
        warn = "",
        hint = "",
        info = "",
    },
    severity_sort = true,
    virtual_text = true,
}

-- NOTE: I need a better way of managing lsp servers??
-- https://github.com/hinell/lsp-timeout.nvim

lsp.packages = {
    ["nvim-lspconfig"] = {
        "neovim/nvim-lspconfig",
        version = "*",
    },
}

lsp.configs = {}
lsp.configs["nvim-lspconfig"] = function()
    -- Lsp Symbols
    local signs = {
        Error = doom.features.lsp.settings.icons.error,
        Warn = doom.features.lsp.settings.icons.warn,
        Info = doom.features.lsp.settings.icons.info,
        Hint = doom.features.lsp.settings.icons.hint,
    }
    local hl = "DiagnosticSign"

    for severity, icon in pairs(signs) do
        local highlight = hl .. severity
        vim.fn.sign_define(highlight, {
            text = icon,
            texthl = highlight,
            numhl = highlight,
        })
    end

    -- TODO: add custom diagnostic handler here
    --  move custom handlers into their own file.

    vim.diagnostic.config({
        virtual_text = doom.features.lsp.settings.virtual_text,
        severity_sort = doom.features.lsp.settings.severity_sort,
        float = {
            show_header = false,
            border = "rounded",
        },
    })
    -- Border for lsp_popups
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = doom.settings.border_style,
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = doom.settings.border_style,
    })
    -- symbols for autocomplete
    local kinds = {}
    for typ, icon in pairs(doom.features.lsp_cmp.settings.completion.kinds) do
        table.insert(kinds, " " .. icon .. " (" .. typ .. ") ")
    end
    vim.lsp.protocol.CompletionItemKind = kinds

    -- suppress error messages from lang servers
    vim.notify = function(msg, log_level, _)
        if msg:match("exit code") then
            return
        end
        if log_level == vim.log.levels.ERROR then
            vim.api.nvim_err_writeln(msg)
        else
            vim.api.nvim_echo({ { msg } }, true, {})
        end
    end
end

local function diagnostics_testing()
    print("--- DIAGNOSTIC TESTING ---")


    print("diagnostics i current buf=", vim.inspect(vim.diagnostic.count(0)))

    print("namespaces = ", vim.inspect(vim.diagnostic.get_namespaces()))

    print("Current diagnostics = ", vim.inspect(vim.diagnostic.get(0)))

    print("next = ", vim.inspect(vim.diagnostic.get_next()))

    -- TODO: Add a new virtual char to all diagnostics.

    print("--- DIAGNOSTIC TESTING END ---")
end

lsp.binds = function()
    return {
        { "K", vim.lsp.buf.hover, name = "Show hover doc" },
        {
            "[d",
            function()
                vim.diagnostic.jump({ count = -1 })
            end,
            name = "Jump to prev diagnostic",
        },
        {
            "]d",
            function()
                vim.diagnostic.jump({ count = 1 })
            end,
            name = "Jump to next diagnostic",
        },
        {
            "g",
            {
                { "D", vim.lsp.buf.declaration, "Jump to declaration" },
                { "d", vim.lsp.buf.definition, name = "Jump to definition" },
                { "r", vim.lsp.buf.references, name = "Jump to references" },
                { "I", vim.lsp.buf.implementation, name = "Jump to implementation" },
                { "a", vim.lsp.buf.code_action, name = "Do code action" },
            },
        },
        {
            "<C-",
            {
                {
                    "p>",
                    function()
                        vim.diagnostic.jump({ count = -1 })
                    end,
                    name = "Jump to prev diagnostic",
                },
                {
                    "n>",
                    function()
                        vim.diagnostic.jump({ count = 1 })
                    end,
                    name = "Jump to next diagnostic",
                },
                {
                    "k>",
                    vim.lsp.buf.signature_help,
                    name = "Show signature help",
                },
            },
        },
        {
            "<leader>",
            name = "+prefix",
            {
                {
                    "c",
                    name = "+code",
                    {
                        { "r", vim.lsp.buf.rename, name = "Rename" },
                        { "a", vim.lsp.buf.code_action, name = "Do action" },
                        { "t", vim.lsp.buf.type_definition, name = "Jump to type" },
                        { "D", vim.lsp.buf.declaration, "Jump to declaration" },
                        {
                            "k",
                            name = "+diagnostics",
                            {
                                {
                                    "t",
                                    function()
                                        diagnostics_testing()
                                    end,
                                    name = "diagnostics testing",
                                },
                            },
                        },
                        { "d", vim.lsp.buf.definition, name = "Jump to definition" },
                        { "R", vim.lsp.buf.references, name = "Jump to references" },
                        { "i", vim.lsp.buf.implementation, name = "Jump to implementation" },
                        {
                            "l",
                            name = "+lsp",
                            {
                                { "i", "<cmd>LspInfo<CR>", name = "Inform" },
                                { "r", "<cmd>LspRestart<CR>", name = "Restart" },
                                { "s", "<cmd>LspStart<CR>", name = "Start" },
                                { "d", "<cmd>LspStop<CR>", name = "Disconnect" },
                                { "m", "<cmd>Mason<CR>", name = "Mason" },
                                { "M", "<cmd>MasonLog<CR>", name = "MasonLog" },
                            },
                        },
                        {
                            "d",
                            name = "+diagnostics",
                            {
                                { "[", vim.diagnostic.goto_prev, name = "Jump to prev" },
                                { "]", vim.diagnostic.goto_next, name = "Jump to next" },
                                { "p", vim.diagnostic.goto_prev, name = "Jump to prev" },
                                { "n", vim.diagnostic.goto_next, name = "Jump to next" },
                                {
                                    "L",
                                    function()
                                        vim.diagnostic.open_float(0, {
                                            focusable = false,
                                            border = doom.settings.border_style,
                                        })
                                    end,
                                    name = "Line",
                                },
                                { "l", vim.diagnostic.setloclist, name = "Loclist" },
                            },
                        },
                    },
                },
            },
        },
    }
end

return lsp
