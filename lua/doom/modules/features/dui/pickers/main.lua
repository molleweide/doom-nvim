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
    SETTINGS = function() end,
    MODULES = function()
        require("doom.modules.features.dui.picker").picker(
            require("doom.modules.features.dui.pickers.modules")
        )
    end,
    PACKAGES = function() end,
    COMMANDS = function() end,
    AUTOCMDS = function() end,
    BINDINGS = function() end,
    SNIPPETS = function() end,
}

picker_main.results_title = "[Select]"

picker_main.finder = require("telescope.finders").new_table({
    results = (function()
        local res = {}
        for k, _ in pairs(doom_main_menu_results) do
            table.insert(res, k)
        end
        return res
    end)(),
    entry_maker = function(entry)
        return {
            value = entry,
            display = entry,
            ordinal = entry,
        }
    end,
})

picker_main.sorter = require("telescope.config").values.generic_sorter()

picker_main.attach_mappings = function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        doom_main_menu_results[entry.value]()
    end)
    return true
end

return picker_main
