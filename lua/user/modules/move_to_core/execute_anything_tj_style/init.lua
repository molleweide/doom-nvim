local autocmds_service = require("doom.services.autocommands")

-- TODO: rename to: buffer_monitors

local buffer_monitors_namespace = "DoomBufferMonitors"

local M = {}

-- TEST: How can I stop the process after it has been started?
-- >>> I need a picker to list all existing autocmds

-- Rename to spawn_buffer_monitor()
local attach_to_buffer = function(opts)
    opts = opts or {}

    -- TODO: check if buf with same name already exists.

    local complete_name_string =
        string.format("%s @ %s : %s", buffer_monitors_namespace, opts.name, opts.description)

    print(complete_name_string)

    if not opts.buf then
        local get_ls = vim.tbl_filter(function(buf)
            return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
        end, vim.api.nvim_list_bufs())

        vim.tbl_map(function(id)
            if complete_name_string == vim.api.nvim_buf_get_name(id) then
                opts.buf = id
            end
        end, get_ls)
    end

    if not opts.buf then
        local buf = vim.api.nvim_create_buf(true, true)
        -- -- set the name of the new buf
        vim.api.nvim_buf_set_name(buf, complete_name_string)
        vim.api.nvim_open_win(buf, false, {
            split = "right",
            -- win = 0,
        })
    end

    local append_data = function(_, data)
        if data then
            vim.api.nvim_buf_set_lines(opts.buf, -1, -1, false, data)
        end
    end

    print(vim.inspect(opts))

    if false then
        autocmds_service.set("BufWritePost", opts.pattern, function()
            vim.api.nvim_buf_set_lines(opts.buf, 0, -1, false, { "TESTING" })

            if type(opts.command) == "table" then
                vim.fn.jobstart(opts.command, {
                    stdout_buffered = true,
                    on_stdout = append_data,
                    on_stderr = append_data,
                })
            elseif type(opts.command) == "function" then
                opts.command(opts.args)
            end
        end, {
            group = buffer_monitors_namespace,
            desc = string.format("%s : %s", opts.name, opts.description),
        })
    end
end

M.cmds = {
    {
        "DoomAddBufferMonitor",
        function()
            attach_to_buffer({
                name = vim.fn.input("Job name: "),
                buf = tonumber(vim.fn.input("Bufnr (or empty for new buf): ")),
                pattern = vim.fn.input("Pattern: "),
                command = vim.fn.input("Command: "),
                description = vim.fn.input("Job description: "),
                dry_run = true,
            })
        end,
    },
    {
        "Doomdebugbinds",
        function()
            attach_to_buffer({
                name = "Debug binds",
                buf = tonumber(vim.fn.input("Bufnr (or empty for new buf): ")),
                pattern = "%",
                require("doom.modules.core.nest.mapper.main").get_match_for_keybind,
                description = vim.fn.input("Job description: "),
                args = {},
            })
        end,
    },
}

return M
