local utils = require("doom.utils")
local system = require("doom.core.system")
local fs = require("doom.utils.fs")
local job = require("plenary.job")

local M = {}

-- Make the text that is displayed in the preview
local function record_buf_lines(record)
    local lines = {}

    local modes = {}
    local mode_str = ""

    if type(record.mode) == "table" then
        modes = record.mode
    else
        table.insert(modes, record.mode)
    end

    for i, mode in ipairs(modes) do
        if i > 1 then
            mode_str = mode_str .. ", "
        end

        if mode == "n" then
            mode_str = mode_str .. "normal"
        elseif mode == "i" then
            mode_str = mode_str .. "insert"
        elseif mode == "v" then
            mode_str = mode_str .. "visual"
        elseif mode == "t" then
            mode_str = mode_str .. "terminal"
        elseif mode == "o" then
            mode_str = mode_str .. "operator pending"
        elseif mode == "s" then
            mode_str = mode_str .. "select"
        elseif mode == "r" then
            mode_str = mode_str .. "replace"
        else
            mode_str = mode_str .. mode
        end
    end

    local filename
    local row
    local cmd_str
    if record.filename ~= nil then
        filename = record.filename:gsub(vim.g.mapper_search_path .. "/", "")
    else
        filename = ""
    end
    if record.row ~= nil then
        row = record.row
    else
        row = ""
    end
    if type(record.cmd) == "function" then
        cmd_str = "function"
    else
        cmd_str = record.cmd
    end

    local function flatten_inspect(t)
        return vim.inspect(t):gsub("\n", ""):gsub("{  ", "{"):gsub("  ", " ")
    end

    table.insert(lines, "Id:           " .. record.unique_identifier)
    table.insert(lines, "Category:     " .. record.category)
    table.insert(lines, "Mode:         " .. mode_str)
    table.insert(lines, "Keys:         " .. record.keys)
    table.insert(lines, "Command:      " .. cmd_str)
    table.insert(lines, "Buffer only:  " .. tostring(record.buffer_only))
    table.insert(lines, "Options:      " .. flatten_inspect(record.options))
    table.insert(lines, "Definition:   " .. filename .. ":" .. row)
    table.insert(lines, "Origin:       " .. record.module_origin)
    table.insert(lines, "")
    table.insert(lines, record.description)

    return lines
end

-- Fetches mapper information to be passed to picker
M.get_mappers = function()
    -- Search path
    local search_dir = vim.g.mapper_search_path

    -- Initialization
    -- local records = require('nvim-mapper').mapper_records

    local records = _G._doom.bindings_unique

    -- local regex_table = {}

    if records == nil then
        return {}
    end

    -- -- For each record, build a regex
    -- for unique_identifier, record in pairs(records) do
    --   local regex = '\\((.+,\\s*)+"' .. unique_identifier .. '"\\s*,.+\\)'
    --   table.insert(regex_table, regex)
    --   record.regex = regex
    -- end
    --
    -- -- Use rg to find all of these regex in one run
    -- local rg_regex = "(" .. table.concat(regex_table, "|") .. ")"
    -- job:new({
    --   command = "rg",
    --   args = {
    --     rg_regex, search_dir, "--color=never",
    --     "--line-number",
    --     "--multiline",
    --     "--multiline-dotall",
    --   },
    --   cwd = "/usr/bin",
    --   on_exit = function(j, return_val)
    --     if (return_val ~= 0) then
    --       print("Rg error")
    --       -- return
    --     end
    --
    --     vim.g.nvim_mapper_rg_output = j:result()
    --   end
    -- }):sync()
    --
    -- -- Scan the output to match the results with the mappings
    -- local rg_output = vim.g.nvim_mapper_rg_output
    --
    -- for i, _ in pairs(rg_output) do
    --   local rg_record = rg_output[i]
    --   for j, _ in pairs(records) do
    --     if (string.find(rg_record, records[j].unique_identifier) ~= nil) then
    --       -- Get the file path and line number for mappings
    --       local rg_record_split = vim.split(rg_record, ":")
    --
    --       -- Get file path
    --       records[j].filename = rg_record_split[1]
    --
    --       -- Get line number
    --       records[j].row = tonumber(rg_record_split[2])
    --       records[j].col = 0
    --     end
    --   end
    -- end

    -- Create the mapping scratch buffers text
    for _, record in pairs(records) do
        record.lines = record_buf_lines(record)
    end

    -- Telescope wants an indexed array
    local indexed_records = {}
    for _, record in pairs(records) do
        local mode_str
        if type(record.mode) == "table" then
            mode_str = table.concat(record.mode, ", ")
        else
            mode_str = record.mode
        end

        record.mode = mode_str
        table.insert(indexed_records, record)
    end

    return indexed_records
end

-- local function util_ensure_no_linesplits(data)
--     if type(data) == "string" then
--         data = vim.split(data, "\n")
--         -- data = { data }
--     end
--     return data
-- end

local function getLastControlChar(keybinds)
    local lastControlChar = nil
    local pattern = "<C%-.>"
    local pattern2 = "<F%d>"
    local pattern3 = "<A%-.>"
    for match in string.gmatch(keybinds, pattern) do
        lastControlChar = match -- Update lastControlChar to the current match
    end
    return lastControlChar
end

M.get_last_char = function(keys)
    local has_last_control_char = getLastControlChar(keys)
    if has_last_control_char then
        return has_last_control_char
    else
        return keys:sub(-1)
    end
end

-- WARN: These sequences fail:
-- ---------------------------------
--      <c-z>
--      <leader>r<cr>
--      ;
--      :
--      ,
--      <C-Left>
--      |
-- ---------------------------------
--  ^ Okay, so it turns out that small letters do not work.
--  ^ Special characters also dont work.
--
M.parse_key_sequence = function(keys)
    local ret = {}
    local patterns = {
        { "<leader>", 8 },
        { "<C%-.>",   5 },
        { "<A%-.>",   5 },
        { "<F%d>",    4 },
        { "%a",       1 },
        { "%p",       1 },
        -- "<A%-.>",
    }
    local i = 1
    while i < keys:len() + 1 do
        local pi = 1
        local pat
        local has_match = false
        while not has_match or pi <= #patterns do
            pat = patterns[pi]

            -- print("pat:", pat, pi, #patterns, has_match)

            local ok, substr = pcall(string.sub, keys, i, i + pat[2] - 1)

            -- substr = utils.escape_str(substr)

            if ok then
                if substr:match(pat[1]) then
                    -- print("MATCH = ", check_this)
                    has_match = true
                    table.insert(ret, substr)
                    i = i + pat[2]
                end
                -- print(substr, pat[1], has_match)
            end
            pi = pi + 1
        end
        if not has_match then
            return "no match"
        end
    end

    return ret
end

M.get_short_path_from_module_origin = function(module_origin)
    local parts = vim.split(module_origin, "%.")
    local module_init_file = table.concat(parts, "/") .. "/init.lua"
    local module_path = system.doom_configs_root .. "/lua/doom/modules/" .. module_init_file
    local status
    if fs.file_exists(module_path) then
        status = "doom"
    else
        module_path = system.doom_configs_root .. "/lua/user/modules/" .. module_init_file
        if fs.file_exists(module_path) then
            status = "user"
        end
    end
    local s, e = module_path:find("lua/")
    -- print("[NEST PICKERS:]", status, module_path)
    return module_path:sub(e)
end

M.get_abs_path_from_module_origin = function(module_origin)
    local parts = vim.split(module_origin, "%.")
    local module_init_file = table.concat(parts, "/") .. "/init.lua"
    local module_path = system.doom_configs_root .. "/lua/doom/modules/" .. module_init_file
    local status
    if fs.file_exists(module_path) then
        status = "doom"
    else
        module_path = system.doom_configs_root .. "/lua/user/modules/" .. module_init_file
        if fs.file_exists(module_path) then
            status = "user"
        end
    end
    -- print("[NEST PICKERS:]", status, module_path)
    return module_path
end

return M
