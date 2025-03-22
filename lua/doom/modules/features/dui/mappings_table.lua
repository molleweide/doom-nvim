-- NOTE: The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.
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

    -- ENTRY ITEM: MODULE
    --
    -- When an entry represents a full module, then these binds will apply
    -- to that entry.
    modules = {
        -- EDIT
        ["<CR>"] = {
            desc = "Edit module",
            action = function(prompt_bufnr, entry, key)
                -- DOOM_UI_STATE.selected_module = fuzzy.value
                -- ax.m_edit(fuzzy.value)
                P(entry.value)
                -- print(("Hi from mappigs: %s"):format(key))
                -- print(entry.value.path_init)
                actions.close(prompt_bufnr)
                vim.cmd(string.format("edit %s", entry.value.path_init))
            end,
        },
        -- INSPECT MODULE
        ["<C-a>"] = {
            action = function(fuzzy, line, key)
                print(("Hi from mappigs: %s"):format(key))
                -- DOOM_UI_STATE.query = {
                --     type = "SHOW_SINGLE_MODULE",
                --     -- components = {}
                -- }
                -- DOOM_UI_STATE.selected_module = fuzzy.value
                -- DOOM_UI_STATE.next()
            end,
        },

        ["<C-b>"] = {
            action = function(fuzzy, _)
                -- DOOM_UI_STATE.query = {
                --   type = "MODULE_COMPONENT",
                --   -- components = {}
                -- }
                -- DOOM_UI_STATE.selected_component = fuzzy.value
                -- DOOM_UI_STATE.next()
            end,
        },
        ["<C-e>"] = {
            action = function(prompt_bufnr, entry, key)
                -- ax.m_create(sel, line)
                print("CONTROL E:")
                P(entry)
            end,
        },
        ["<C-r>"] = {
            action = function(fuzzy, _) -- note: atm it seems that ^r closes the window or does something wierd. registers?!
                -- ax.m_rename(fuzzy.value)
            end,
        },
        ["<C-x>"] = {
            action = function(fuzzy, _)
                -- ax.m_delete(fuzzy.value)
            end,
        },
        ["<C-t>"] = {
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
                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        targets = target_modules,
                        action = choice,
                    })
                end)
            end,
        },
        ["<C-y>"] = {
            action = function(fuzzy, _)
                -- ax.m_move(fuzzy.value)
            end,
        },
        ["<C-h>"] = {
            action = function(fuzzy, _)
                -- ax.m_merge()
            end,
        },
        ["<C-q>"] = {
            action = function(fuzzy, _)
                -- ax.m_submit_module_to_upstream()
            end,
        },

        ["<Tab>"] = { action = actions.toggle_selection + actions.move_selection_worse },
        ["<S-Tab>"] = { action = actions.toggle_selection + actions.move_selection_better },
    },
}

return mappings
