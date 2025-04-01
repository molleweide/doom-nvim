-- The idea is to keep all mappings in this table for all categories
-- of dui pickers and then use this look up upon trying to run a specific
-- action for an bind.
-- This allows for keeping all bindings on one place here, and then I access
-- the bindings with the `picker_state.entry.category`.
local log = require("doom.utils.logging")

local utils = require("doom.utils")
local mu = require("doom.utils.modules")

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

local function validate_user_input(user_input)
    if not user_input then
        return
    end
    if user_input:match("[^%w_/]") then
        log.warn("user input contains invalid characters")
        return
    end
    return true
end

local function make_new_target(user_input, selection)
    local t_path_user_input = vim.split(user_input, "/")

    print("t_path_user_input:", vim.inspect(t_path_user_input))
    local new = {}
    -- handle origin
    if t_path_user_input[1]:match("^(doom|user)$") then
        new.origin = table.remove(t_path_user_input, 1)
        table.insert(table.remove(t_path_user_input)) -- new name
        new.t_section = t_path_user_input
    else
        new.origin = selection.origin
        table.insert(new, table.remove(t_path_user_input)) -- rename old name
        -- create table path by combining current selection with the new segment
        local t_path_sel = vim.deepcopy(selection.t_path)
        table.remove(t_path_sel)
        new.t_section = utils.list_merge(t_path_sel, t_path_user_input)
    end
    return new
end

local mappings = {

    -- TODO: Prevent modifying core modules.

    -- ENTRY ITEM: MODULE
    --
    -- When an entry represents a full module, then these binds will apply
    -- to that entry.
    --
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
                    if not validate_user_input(user_input) then
                        return
                    end
                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        action = "ADD",
                        {
                            mu.DoomModuleEnabled(make_new_target(user_input, v)),
                        },
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
                local Path = require("pathlib")
                local actions = require("telescope.actions")
                local selection = current_picker__get_selected_entries()
                -- if #selection > 1 then
                --     log.warn("Mult selection is not supported yet!")
                --     return
                -- end

                actions.close(prompt_bufnr)

                local action_old = {
                    action = "REMOVE",
                }
                local action_new = {
                    action = "ADD",
                }

                local function move_multiple()
                    local sel_idx = #action_old + 1

                    -- apply actions
                    if sel_idx > #selection then
                        if #selection > 0 then
                            require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                                action_old,
                                action_new,
                            })
                        end
                        return
                    end

                    local v = selection[#action_old + 1].value

                    local selected_section_str =
                        string.format("%s.%s.%s", v.origin, v.section, v[1])

                    log.info("selecteion:", v.origin, v.section, v[1])

                    vim.ui.input({
                        prompt = string.format(
                            [[:: Move/rename module(s); selection = (%s) | Num %s of %s ::
A. Input single string (without "."!!) to rename the module.
B. Input a lua dot path to move module to new section.
C. Prefix path with "user", eg "user.my.new.name", to move module to [user/modules/..]
* If you ommit doom/user prefix, then modules are moved under same origin as selection.
                        ]],
                            selected_section_str,
                            #action_old + 1,
                            #selection
                        ),
                    }, function(user_input)
                        if not validate_user_input(user_input) then
                            return
                        end
                        table.insert(action_old, v)
                        table.insert(
                            action_new,
                            mu.DoomModuleEnabled(make_new_target(user_input, v))
                        )

                        move_multiple()
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

                local action = {
                    action = "REMOVE",
                }

                -- manage_modules_tree({
                --      {
                --           action = REMOVE,
                --           {},{},{},...
                --      },
                --      {
                --          action = ADD,
                --          {},{},{}, ...
                --      }
                -- })

                for i, sel in ipairs(selection) do
                    local s = sel.value
                    -- confirm_prompt = confirm_prompt
                    --     .. "\n"
                    --     .. i
                    --     .. ": "
                    --     .. string.format("%s.%s.%s", s.origin, s.section, s[1])
                    table.insert(action, s)
                end

                vim.ui.select({ "yes", "no" }, {
                    prompt = confirm_prompt,
                    -- format_item = function(item)
                    --     return .. item
                    -- end,
                }, function(choice)
                    log.info(string.format("Set selected module to [%s]", choice))

                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        action,
                    })
                end)
            end,
        },
        -- TODO: ui.input -> prefill with current tags if exists.
        -- TODO: if make no tags, then remove tags table.
        ["<C-q>"] = {
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

        ["<C-t>"] = {
            desc = "Set status [enabled|disabled]",
            action = function(prompt_bufnr, entry, key) -- TOGGLE MODULE(S)
                local selection = current_picker__get_selected_entries()

                local action_set = {}
                vim.iter(selection):each(function(entry)
                    table.insert(action_set, entry)
                end)

                vim.ui.select({ "ENABLE", "DISABLE" }, {
                    prompt = "Select enable or disable:",
                    format_item = function(item)
                        return "I'd like to choose " .. item
                    end,
                }, function(choice)
                    log.info(string.format("Set selected module to [%s]", choice))
                    action_set.action = choice
                    require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                        action_set,
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
