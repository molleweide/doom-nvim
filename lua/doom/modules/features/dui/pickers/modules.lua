local log = require("doom.utils.logging")
local constants = require("doom.modules.features.dui.pickers.constants")
local picker_utils = require("doom.modules.features.dui.pickers.utils")
local mappings_table = require("doom.modules.features.dui.mappings_table")

local insert_chars = constants.insert_chars

local entry_display = require("telescope.pickers.entry_display")

local modules_ok, enabled_modules = require("doom.core.modules").enabled_modules()
if not modules_ok then
    log.error("Could not load enabled modules!")
end

log.info("DOOM MODULES PICKER V2")

local enabled_count = 0
local section_width = 0

local results = require("doom.utils.modules").get_modules_list_with_origins(
    enabled_modules,
    function(mod)
        section_width = math.max(section_width, #mod.section)

        if mod.enabled then
            enabled_count = enabled_count + 1
        end
    end
)

local displayer = entry_display.create({
    separator = "| ",
    items = {
        { width = 7 },
        { width = 2 },
        { width = 5 },
        { width = section_width + 1 },
        { remaining = true },
    },
})

local function make_display(entry)
    return displayer({
        { "MODULE", "TSConstant" },
        { entry.value.enabled and "x" or " ", "TelescopeResultsIdentifier" },
        { entry.value.missing and "NULL" or entry.value.origin },
        { entry.value.section, "TelescopeResultsIdentifier" },
        {
            entry.value[1] .. (entry.value.missing and " (module file missing)" or ""),
            entry.value.enabled and "" or "ErrorMsg",
        },
    })
end

local picker_modules = {}

picker_modules.prompt_title = picker_utils.make_title("MAIN MENU")

picker_modules.layout_config = {
    width = 0.5,
    center = {
        width = 0.8,
    },
}

picker_modules.finder = require("telescope.finders").new_table({
    results = results,
    entry_maker = function(entry)
        return {
            value = entry,
            display = make_display,
            ordinal = entry[1],
        }
    end,
})

picker_modules.sorter = require("telescope.config").values.generic_sorter()

picker_modules.attach_mappings = function(prompt_bufnr, map)
    local state = require("telescope.actions.state")
    local function call_mappings_func(key)
        local entry = state.get_selected_entry(prompt_bufnr)

        -- NOTE: Now, with refreshing capabilities, passing the function here is unnecessary,
        -- since we can just call the main picker function, with this file opts, instead.
        mappings_table["modules"][key].action(prompt_bufnr, entry, key, doom_modules_picker_v2)

    end
    for _, key in ipairs(insert_chars) do
        if mappings_table["modules"][key] then
            map("i", key, function()
                call_mappings_func(key)
            end, {
                desc = mappings_table["modules"][key].desc and mappings_table["modules"][key].desc
                    or "todo...",
            })
        end
    end
    return true
end

picker_modules.initial_mode = "insert"

return picker_modules
