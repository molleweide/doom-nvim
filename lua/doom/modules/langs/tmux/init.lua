local tmux = {}

-- TODO: Install custom language server
-- https://github.com/Freed-Wu/tmux-language-server
-- ?? How to install custom language server.
--

----------------------------
-- SETTINGS
----------------------------

-- tmux.settings = {}

----------------------------
-- PACKAGES
----------------------------

-- https://github.com/Freed-Wu/tmux-language-server

-- tmux.packages = {
-- [""] = {},
-- -- [""] = {},
-- -- [""] = {},
-- -- [""] = {},
-- }

----------------------------
-- CONFIGS
----------------------------

----------------------------
-- CMDS
----------------------------

-- tmux.cmds = {}

--------------------------
-- AUTOCMDS
--------------------------

-- tmux.autocmds = {}

    -- vim.api.nvim_create_autocmd('FileType', {
    --   -- This handler will fire when the buffer's 'filetype' is "python"
    --   pattern = 'tmux.conf',
    --   callback = function(ev)
    --     vim.lsp.start({
    --       name = 'my-server-name',
    --       cmd = {'name-of-language-server-executable', '--option', 'arg1', 'arg2'},
    --       -- Set the "root directory" to the parent directory of the file in the
    --       -- current buffer (`ev.buf`) that contains either a "setup.py" or a
    --       -- "pyproject.toml" file. Files that share a root directory will reuse
    --       -- the connection to the same LSP server.
    --       root_dir = vim.fs.root(ev.buf, {'setup.py', 'pyproject.toml'}),
    --     })
    --   end,
    -- })


----------------------------
-- BINDS
----------------------------

-- tmux.binds = {}

----------------------------
-- LEADER BINDS
----------------------------

-- if require("doom.utils").is_module_enabled("whichkey") then
--   table.insert(tmux.binds, {
--     "<leader>",
--     name = "+prefix",
--     {
--       {
--         "YYY",
--         name = "+ZZZ",
--         {
--         -- first level
--         },
--       },
--     },
--   })
-- end

----------------------------
-- RETURN
----------------------------

return tmux
