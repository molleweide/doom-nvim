-- NOTE: The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.
local log = require("doom.utils.logging")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local action_utils = require("telescope.actions.utils")

local function current_picker__get_selected_entries()
    local prompt_bufnr = vim.api.nvim_get_current_buf()
    -- local current_picker = action_state.get_current_picker(prompt_bufnr)
    local results = {}
    action_utils.map_selections(prompt_bufnr, function(entry, index)
        -- P(entry)
        -- results[index] = entry.value
        table.insert(results, entry)
    end)
    return results
end

local mappings = {

    -- TODO: add tags to module.

    -- ENTRY ITEM: MODULE
    --
    -- When an entry represents a full module, then these binds will apply
    -- to that entry.
    modules = {
        ["<CR>"] = {
            desc = "Edit module",
            action = function(prompt_bufnr, entry, key)
                actions.close(prompt_bufnr)
                vim.cmd(string.format("edit %s", entry.value.path_init_file))
            end,
        },
        ["<C-s>"] = {
            desc = "UI Menu",
            action = function(fuzzy, line, key)
                print(("Hi from mappigs: %s"):format(key))
            end,
        },
        ["<C-l>"] = {
            desc = "UI Menu",
            action = function(fuzzy, line, key)
                print(("Hi from mappigs: %s"):format(key))
            end,
        },
        ["<C-a>"] = {
            desc = "Browse [module.autocmds]",
            action = function(fuzzy, line, key)
                print(("Hi from mappigs: %s"):format(key))
            end,
        },

        ["<C-d>"] = {
            desc = "Browse [module.cmds]",
            action = function(prompt_bufnr, entry, key) end,
        },
        ["<C-b>"] = {
            desc = "Browse [module.bindings]",
            action = function(fuzzy, _) end,
        },

        -- TODO: if path begins with [.] or [doom], then add module to new
        -- section under [doom/modules]
        -- TODO: if path begins with [user] then add new section to user.
        -- TODO: else add new module starting from selected modules section.
        -- TODO: handle/prevent mult select??
        ["<C-e>"] = {
            desc = "Add new module",
            action = function(prompt_bufnr, entry, key)
                local v = entry.value
                local to_section = string.format("%s.%s.%s", v.origin, v.section, v[1])

                log.info(v.origin, v.section, v[1])

                actions.close(prompt_bufnr)
                vim.ui.input({
                    prompt = string.format(
                        "Add module to same section [%s]; Enter new name/subpath: ",
                        to_section
                    ),
                }, function(module_target_name)
                    if not module_target_name then
                        return
                    end

                    log.info(
                        string.format("Add [%s] to section [%s]", module_target_name, to_section)
                    )

                    -- local split_on_whitespace = vim.split(module_target_name, " ")
                    -- local move_to_destination
                    -- if #split_on_whitespace > 1 then
                    --     module_target_name = split_on_whitespace[1]
                    --     move_to_destination = split_on_whitespace[2]
                    -- end
                end)
            end,
        },
        -- TODO: prevent multi select.
        -- ^ maybe if multiple, then queue vim.ui.inputs to change each module, collect
        -- all changes, and perform the updates at the end.
        ["<C-r>"] = {
            desc = "Rename module",
            action = function(fuzzy, _) -- note: atm it seems that ^r closes the window or does something wierd. registers?!
            end,
        },
        -- TODO: are you sure?!
        ["<C-x>"] = {
            desc = "Delete selected module(s)",
            action = function(fuzzy, _) end,
        },
        ["<C-t>"] = {
            desc = "Set status [enabled|disabled]",
            action = function(_, entry, key) -- TOGGLE MODULE(S)
                print("CONTROL T")

                -- get multiple or single selection
                local selection = current_picker__get_selected_entries()
                if #selection == 0 then
                    selection = { action_state.get_selected_entry() }
                end

                -- P(selection)

                print(
                    ("entry.value.enabled: %s -> %s"):format(
                        entry.value.enabled,
                        not entry.value.enabled
                    )
                )
                entry.value.enabled = not entry.value.enabled

                -- Doesnt work for modifying entries internal values. it does
                -- not trigger a refresh. telescope does not have this feature
                -- yet.
                -- action_state.get_current_picker(prompt_bufnr):refresh()

                local Path = require("pathlib")
                local target_modules = vim.iter(selection)
                    :map(function(entry)
                        return {
                            target_module_name = entry.value.name,
                            target_module_dir = Path(entry.value.path),
                        }
                    end)
                    :totable()

                print("????")

                vim.ui.select({ "ENABLE", "DISABLE" }, {
                    prompt = "Select enable or disable:",
                    format_item = function(item)
                        return "I'd like to choose " .. item
                    end,
                }, function(choice)
                    log.info(string.format("Set selected module to [%s]", choice))

                    -- require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                    --     targets = target_modules,
                    --     action = choice,
                    -- })
                end)
            end,
        },
        -- TODO: if single string, then simply rename
        -- TODO: if including back slashes, then move selected module
        -- to new section
        -- TODO: check if path segment already exists, mkdirp for non existent dirs.
        ["<C-w>"] = {
            desc = "Move module(s)",
            action = function(fuzzy, _) end,
        },
        ["<C-z>"] = {
            desc = "Copy core mod to user + edit",
            action = function(prompt_bufnr, entry, key)
                log.info("copy core module to user:", entry.value[1])
            end,
        },
        ["<Tab>"] = {
            desc = "select forward",
            action = actions.toggle_selection + actions.move_selection_worse,
        },
        ["<S-Tab>"] = {
            desc = "select backwards",
            action = actions.toggle_selection + actions.move_selection_better,
        },
    },
}

return mappings
