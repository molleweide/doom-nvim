local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")

local doom_autocmds_namespace = require("doom.services.autocommands").namespace

local conf = require("telescope.config").values

-- local autocmds = vim.api.nvim_get_autocmds({})

local all = vim.api.nvim_get_autocmds({})
local autocmds = {}
for i, v in ipairs(all) do
    if v.group_name then
        -- print(v.group_name, doom_autocmds_namespace)
        if
            v.group_name == doom_autocmds_namespace
            or v.group_name == doom.features.monitoring.buffer_monitors_namespace
        then
            -- print(v.group_name, doom_autocmds_namespace, v.pattern)
            table.insert(autocmds, v)
        end
    end
end

table.sort(autocmds, function(lhs, rhs)
    return lhs.event < rhs.event
end)

local picker_autocmds = {}
local opts = {}

picker_autocmds.prompt_title = "autocommands"
picker_autocmds.finder = finders.new_table({
    results = autocmds,

    -- FIX: why isnt my descriptions showing?
    entry_maker = opts.entry_maker or make_entry.gen_from_autocommands(opts),
})

-- I need to have a custom previewer for doom so that I can show name and
-- description
picker_autocmds.previewer = previewers.autocommands.new(opts)

picker_autocmds.sorter = conf.generic_sorter(opts)
picker_autocmds.attach_mappings = function(prompt_bufnr)
    action_set.select:replace_if(function()
        local selection = action_state.get_selected_entry()
        if selection == nil then
            return false
        end
        local val = selection.value
        local cb = val.callback
        if vim.is_callable(cb) then
            if type(cb) ~= "string" then
                local f = type(cb) == "function" and cb or rawget(getmetatable(cb), "__call")
                local info = debug.getinfo(f, "S")
                local file = info.source:match("^@(.+)")
                local lnum = info.linedefined
                if file and (lnum or 0) > 0 then
                    selection.filename, selection.lnum, selection.col = file, lnum, 1
                    return false
                end
            end
        end
        local group_name = val.group_name ~= "<anonymous>" and val.group_name or ""
        local output = vim.fn.execute(
            "verb autocmd " .. group_name .. " " .. val.event .. " " .. val.pattern,
            "silent"
        )
        for line in output:gmatch("[^\r\n]+") do
            local source_file = line:match("Last set from (.*) line %d*$")
                or line:match("Last set from (.*)$")
            if source_file and source_file ~= "Lua" then
                selection.filename = source_file
                local source_lnum = line:match("line (%d*)$") or "1"
                selection.lnum = tonumber(source_lnum)
                selection.col = 1
                return false
            end
        end
        return true
    end, function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        print("You selected autocmd: " .. vim.inspect(selection.value))
    end)

    return true
end

return picker_autocmds
