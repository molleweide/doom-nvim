-- NOTE: The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.

local mappings = {
    modules = {
        -- EDIT
        ["<CR>"] = function(fuzzy, line, key)
            -- DOOM_UI_STATE.selected_module = fuzzy.value
            -- -- ax.m_edit(fuzzy.value)
            print(( "Hi from mappigs: %s" ):format(key))
        end,
        -- INSPECT MODULE
        ["<C-a>"] = function(fuzzy, line, key)
            print(( "Hi from mappigs: %s" ):format(key))
            -- DOOM_UI_STATE.query = {
            --     type = "SHOW_SINGLE_MODULE",
            --     -- components = {}
            -- }
            -- DOOM_UI_STATE.selected_module = fuzzy.value
            -- DOOM_UI_STATE.next()
        end,

        ["<C-b>"] = function(fuzzy, _)
            -- DOOM_UI_STATE.query = {
            --   type = "MODULE_COMPONENT",
            --   -- components = {}
            -- }
            -- DOOM_UI_STATE.selected_component = fuzzy.value
            -- DOOM_UI_STATE.next()
        end,
        ["<C-e>"] = function(sel, line)
            -- ax.m_create(sel, line)
        end,
        ["<C-r>"] = function(fuzzy, _) -- note: atm it seems that ^r closes the window or does something wierd. registers?!
            -- ax.m_rename(fuzzy.value)
        end,
        ["<C-x>"] = function(fuzzy, _)
            -- ax.m_delete(fuzzy.value)
        end,
        ["<C-l>"] = function(fuzzy, _)
            -- ax.m_toggle(fuzzy.value)
        end,
        ["<C-y>"] = function(fuzzy, _)
            -- ax.m_move(fuzzy.value)
        end,
        ["<C-h>"] = function(fuzzy, _)
            -- ax.m_merge()
        end,
        ["<C-q>"] = function(fuzzy, _)
            -- ax.m_submit_module_to_upstream()
        end,
    },
}

return mappings
