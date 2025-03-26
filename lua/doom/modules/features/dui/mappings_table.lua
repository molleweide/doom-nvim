-- NOTE: The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.
local log = require("doom.utils.logging")

local function current_picker__get_selected_entries()
    local action_state = require("telescope.actions.state")
    local action_utils = require("telescope.actions.utils")

    local prompt_bufnr = vim.api.nvim_get_current_buf()
    local results = {}
    action_utils.map_selections(prompt_bufnr, function(entry, index)
        -- P(entry)
        -- results[index] = entry.value
        table.insert(results, entry)
    end)
    -- get multiple or single selection
    if #results > 0 then
        return results
    else
        return { action_state.get_selected_entry() }
    end
end

local function validate_chars() end

local mappings = {

    -- TODO: add tags to module.
    -- TODO: move all selected modules to section X

    -- ENTRY ITEM: MODULE
    --
    -- When an entry represents a full module, then these binds will apply
    -- to that entry.
    modules = {
        ["<CR>"] = {
            -- TODO: if mult select load all into buffer.
            desc = "Edit module",
            action = function(prompt_bufnr, entry, key)
                local actions = require("telescope.actions")
                actions.close(prompt_bufnr)
                vim.cmd(string.format("edit %s", entry.value.path_init_file))
            end,
        },
        ["<C-s>"] = {
            -- TODO: extract all actions into functions above, then load a menu
            -- that allows user to select each action.
            -- Some actions may only be available if single selection??
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
        -- TODO: Only allow single selection, OR run browser on the first index of mult selection.
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
        -- TODO: FIRST
        -- TODO: confirm
        ["<C-e>"] = {
            desc = "Prompt: Add new module",
            action = function(prompt_bufnr, entry, key)
                local actions = require("telescope.actions")
                local selection = current_picker__get_selected_entries()
                if #selection > 1 then
                    log.warn("Mult selection is not supported for [ADD]!")
                    return
                end

                local v = selection[1].value
                local selected_section_str = string.format("%s.%s.%s", v.origin, v.section, v[1])

                log.info(v.origin, v.section, v[1])

                actions.close(prompt_bufnr)

                vim.ui.input({
                    prompt = string.format(
                        [[:: ADD NEW MODULE; selection = (%s) ::
-----------------------------------------------------------------------------
A. Create new module from selected section, eg. if selection is "%s"
    an inputing is "new.module" will create "%s.new.module".
B. Prefixing with [.] creates new module starting from same origin as selection;
    ^ eg. ".my.new.module".
C. Prefixing with [doom|user] explicitly creates new module under that origin;
    ^ eg. "doom.my.new.module".
                        ]],
                        selected_section_str,
                        selected_section_str,
                        selected_section_str
                    ),
                }, function(user_input)
                    if not user_input then
                        return
                    end

                    -- validat chars. i believe this includes whitespace.
                    if user_input:match("[^%w_/]") then
                        log.warn("user input contains invalid characters")
                        return
                    end

                    log.info(
                        string.format("Add [%s] to section [%s]", user_input, selected_section_str)
                    )

                    -- everything in manager should go into the manager file.
                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        targets = {
                            {
                                selected_module = v,
                                user_input = user_input,
                            },
                        },
                        action = "ADD",
                    })
                end)
            end,
        },
        -- TODO: completions for all existing sections.
        -- TODO: confirm: yes no
        -- TODO: check if path segment already exists, mkdirp for non existent dirs.
        ["<C-s>"] = {
            desc = "Prompt: Move/rename module",
            action = function(prompt_bufnr, entry, key) -- note: atm it seems that ^r closes the window or does something wierd. registers?!
                local actions = require("telescope.actions")
                local selection = current_picker__get_selected_entries()
                -- if #selection > 1 then
                --     log.warn("Mult selection is not supported yet!")
                --     return
                -- end

                actions.close(prompt_bufnr)

                local targets = {}

                local function move_multiple()
                    local v = selection[#targets+1].value
                    local selected_section_str =
                        string.format("%s.%s.%s", v.origin, v.section, v[1])

                    log.info(v.origin, v.section, v[1])

                    vim.ui.input({
                        prompt = string.format(
                            [[:: Move/rename module(s); selection = (%s) | Num %s of %s ::
A. Input single string (without "."!!) to rename the module.
B. Input a lua dot path to move module to new section.
C. Prefix path with "user", eg "user.my.new.name", to move module to [user/modules/..]
* If you ommit doom/user prefix, then modules are moved under same origin as selection.
                        ]],
                            selected_section_str,
                            #targets+1,
                            #selection
                        ),
                    }, function(user_input)
                        if not user_input then
                            return
                        end

                        -- validat chars. i believe this includes whitespace.
                        if user_input:match("[^%w_/]") then
                            log.warn("user input contains invalid characters")
                            return
                        end

                        log.info(string.format(" [%s]", user_input, selected_section_str))

                        table.insert(targets, {
                            selected_module = v,
                            user_input = user_input,
                        })

                        if #selection > 0 then
                            move_multiple()
                        else
                            -- everything in manager should go into the manager file.
                            require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                                targets = targets,
                                action = "MOVE",
                            })
                        end
                    end)
                end

                move_multiple()
            end,
        },
        -- TODO: confirm: are you sure?!
        ["<C-x>"] = {
            desc = "Delete selected module(s)",
            action = function(prompt_bufnr, entry, key)
                local selection = current_picker__get_selected_entries()
                -- if #selection > 1 then
                --     log.warn("Mult selection is not supported yet!")
                --     return
                -- end

                local actions = require("telescope.actions")

                local v = selection[1].value
                local selected_section_str = string.format("%s.%s.%s", v.origin, v.section, v[1])

                log.info(v.origin, v.section, v[1])

                actions.close(prompt_bufnr)

                local confirm_prompt = string.format("Confirm: Delete #%s modules", #selection)

                local targets = {}

                for i, sel in ipairs(selection) do
                    local s = sel.value
                    -- confirm_prompt = confirm_prompt
                    --     .. "\n"
                    --     .. i
                    --     .. ": "
                    --     .. string.format("%s.%s.%s", s.origin, s.section, s[1])
                    table.insert(targets, { selected_module = s })
                end

                vim.ui.select({ "yes", "no" }, {
                    prompt = confirm_prompt,
                    -- format_item = function(item)
                    --     return .. item
                    -- end,
                }, function(choice)
                    log.info(string.format("Set selected module to [%s]", choice))

                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        targets = target_modules,
                        action = "REMOVE",
                    })
                end)
            end,
        },
        -- TODO: ui.input -> prefill with current tags if exists.
        -- TODO: if make no tags, then remove tags table.
        ["<C-w>"] = {
            desc = "Edit module tags",
            action = function(prompt_bufnr, entry, key)
                local selection = current_picker__get_selected_entries()
                if true then
                    log.warn("Editing [tags] is not yet supported.")
                    return
                end

                if #selection > 1 then
                    log.warn("Mult selection is not supported yet!")
                    return
                end
            end,
        },

        -- TODO: this code is from previous implementation.
        ["<C-t>"] = {
            desc = "Set status [enabled|disabled]",
            action = function(prompt_bufnr, entry, key) -- TOGGLE MODULE(S)
                local selection = current_picker__get_selected_entries()
                if #selection > 1 then
                    log.warn("Mult selection is not supported yet!")
                    return
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

                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        targets = target_modules,
                        action = "TOGGLE",
                    })
                end)
            end,
        },
        -- TODO: check if already exists in user.
        ["<C-z>"] = {
            desc = "Copy core mod to user + edit",
            action = function(prompt_bufnr, entry, key)
                local selection = current_picker__get_selected_entries()
                if #selection > 1 then
                    log.warn("Mult selection is not supported yet!")
                    return
                end
            end,
        },
        ["<Tab>"] = {
            desc = "select forward",
            -- action = actions.toggle_selection + actions.move_selection_worse,
            action = function(prompt_bufnr)
                local actions = require("telescope.actions")
                actions.toggle_selection(prompt_bufnr)
                actions.move_selection_worse(prompt_bufnr)
            end,
        },
        ["<S-Tab>"] = {
            desc = "select backwards",
            action = function(prompt_bufnr)
                local actions = require("telescope.actions")
                actions.toggle_selection(prompt_bufnr)
                actions.move_selection_better(prompt_bufnr)
            end,
        },
    },
}

return mappings
