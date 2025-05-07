local finders = require("telescope.finders")
local strings = require("plenary.strings")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local function mode_highlight(mode)
    if (mode == "i") then
        return "Special"
    elseif (mode == "n") then
        return "SpecialChar"
    elseif (mode == "v") then
        return "Visual"
    else
        return "Normal"
    end
end

-- Creates a Telescope `finder` based on the given options
-- and list of mappers
M.mapper_finder = function(mappers)

    local widths = {
        keys = 0,
        category = 0,
        description = 0,
        mode = 0,
        cmd = 0
    }

    -- The entry has the following keys :
    -- - buffer_only: bool
    -- - category: str
    -- - cmd: str
    -- - keys: str
    -- - mode: str
    -- - options: table
    -- - where_file: str
    -- - where_line: int
    --
    -- We want the display line to be like this :
    -- category mapping description

    -- get max length of result entry attributes
    for _, entry in pairs(mappers) do
        entry.description_display = entry.description
        for key, value in pairs(widths) do
            widths[key] = math.max(value,
                                   strings.strdisplaywidth(entry[key] or ''))
        end
    end

    -- result entry formatting
    local displayer = entry_display.create {
        -- separator = " | ",
        separator = " ▏",
        items = {
            {width = widths.category},
            {width = widths.mode},
            {width = widths.keys},
            {width = widths.description},
            {width = widths.cmd},

        }
    }

    local make_display = function(entry)
        return displayer {
            {entry.category, "TelescopeResultsClass"},
            {entry.mode, mode_highlight(entry.mode)},
            {entry.keys, "TelescopeResultsComment"},
            {entry.description},
        }
    end

    return finders.new_table {
        results = mappers,
        entry_maker = function(entry)
            entry.value = entry.description
            entry.ordinal = entry.description .. entry.unique_identifier .. entry.keys .. entry.category
            entry.display = make_display
            entry.id = entry.unique_identifier
            entry.lines = entry.lines
            return entry
        end
    }
end

return M
