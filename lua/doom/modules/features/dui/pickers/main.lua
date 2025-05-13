-- TODO: define the main doom menu picker
--
--
-- settings
-- modules
-- commands
-- autocmds
-- bindings
-- search (enter a list of useful pickers that you can select from.)
--      ~ plugin manager packages
--      ~ system repos cached / uncached
--      ~ ghq
--
local picker_utils = require("doom.modules.features.dui.pickers.utils")

local picker_main = {}

picker_main.prompt_title = picker_utils.make_title("MAIN MENU")

picker_main.layout_config = {
    width = 0.5,
    center = {
        width = 0.8,
    },
}

local doom_main_menu_results = {
    "settings",
    "modules",
    "packages",
    "commands",
    "autocmds",
    "bindings",
    "snippets",
}

-- TODO: Make this async and see if it works.
picker_main.finder = require("telescope.finders").new_table({
    results = doom_main_menu_results,
    results_title = "[Select]",
    entry_maker = function(entry)
        return {
            value = entry,
            -- display = make_display,
            -- ordinal = entry.ordinal,
        }
    end,
})

picker_main.sorter = require("telescope.config").values.generic_sorter()

return picker_main
