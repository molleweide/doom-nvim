local firenvim = {}

-- Test this when using noice
-- vim.g.firenvim_config.localSettings['.*'] = { cmdline = 'firenvim' }


-- NOTE:
-- vim.fn["firenvim#install"](0) No config detected for chromium. Skipping.
-- vim.fn["firenvim#install"](0) No config detected for librewolf. Skipping.
-- vim.fn["firenvim#install"](0) Installed native manifest for arc.
-- vim.fn["firenvim#install"](0) No config detected for opera. Skipping.
-- vim.fn["firenvim#install"](0) Installed native manifest for brave.
-- vim.fn["firenvim#install"](0) No config detected for ungoogled-chromium. Skipping.
-- vim.fn["firenvim#install"](0) Installed native manifest for chrome-dev.
-- vim.fn["firenvim#install"](0) Installed native manifest for firefox.
-- vim.fn["firenvim#install"](0) Installed native manifest for vivaldi.
-- vim.fn["firenvim#install"](0) Installed native manifest for chrome-canary.
-- vim.fn["firenvim#install"](0) Installed native manifest for chrome.
-- vim.fn["firenvim#install"](0) Installed native manifest for edge.
-- vim.fn["firenvim#install"](0) 0


firenvim.settings = {
    globalSettings = {
        alt = "all",
    },
    localSettings = {
        [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never",
        },
        ["https?://github.com/"] = {
            takeover = "always",
            priority = 1,
        },
    },
    autocmds = {
        { "BufEnter", "github.com", "setlocal filetype=markdown" },
    },
}

firenvim.packages = {
    ["firenvim"] = {
        "glacambre/firenvim",
        -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
        -- lazy = not vim.g.started_by_firenvim,
        -- build = ":call firenvim#install(0)",
        build = function()
            vim.fn["firenvim#install"](0)
        end,
        dev = true,
    },
}

firenvim.configs = {}
firenvim.configs["firenvim"] = function()
    vim.g.firenvim_config = doom.features.firenvim.settings

    for _, command in ipairs(doom.features.firenvim.settings.autocmds) do
        vim.cmd(("autocmd %s %s_*.txt %s"):format(command[1], command[2], command[3]))
    end
end

return firenvim
