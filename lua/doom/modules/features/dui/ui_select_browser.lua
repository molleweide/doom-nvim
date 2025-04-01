local log = require("doom.utils.logging")

-- TODO: I need to visually make dirs vs mod become much clearer
--
-- TODO: Include user modules.
-- ^ This would require using the method that is used in the doom_modules_picker_v2
--
-- TODO: If <CR> on `current` for dir AND no custom name string
-- has bee provided, then prompt user for a new module name.
--
-- migrate this to telescope?

local log = require("doom.utils.logging")

local function __modules_browser_wrap()
    local Path = require("pathlib")

    ---Initialize new module from a target path and a user input name string.
    ---@param path_to any
    local function mod_browser_operate_on_current_dir(path_to)
        vim.ui.input(
            { prompt = string.format("Enter new name for module @ [%s]: ", path_to) },
            function(module_target_name)
                if not module_target_name then
                    return
                end
                local mu = require("doom.utils.modules")

                -- Validate | Do both src and dest?
                if module_target_name:match("[^%a_]") then
                    log.error("!! INVALID MODULE TARGET STRING !!")
                    return
                end

                local split_on_whitespace = vim.split(module_target_name, " ")
                local move_to_destination
                if #split_on_whitespace > 1 then
                    module_target_name = split_on_whitespace[1]
                    move_to_destination = split_on_whitespace[2]
                end

                local t_action_sets = {}

                -- delete
                local action = module_target_name:match("^%-") and "REMOVE"
                if action == "REMOVE" then
                    module_target_name = module_target_name:sub(2)
                    t_action_sets.insert(t_action_sets, {
                        action = "REMOVE",
                        {
                            target_module_name = target_module_name,
                            target_module_dir = path_to / module_target_name,
                        },
                    })
                end

                -- move/rename
                if move_to_destination then
                    action = "MOVE"
                    t_action_sets.insert(t_action_sets, {
                        {
                            action = "REMOVE",
                            {
                                target_module_name = target_module_name,
                                target_module_dir = path_to / module_target_name,
                            },
                        },
                        {
                            action = "ADD",
                            {
                                -- module_spec...
                            },
                        },
                    })
                end

                -- new
                if not action then
                    t_action_sets.insert(t_action_sets, {
                        action = "ACTION",
                        {
                            target_module_name = target_module_name,
                            target_module_dir = path_to / module_target_name,
                        },
                    })
                end

                -- Handle when we are working with [ui_select_browser]

                log.warn("t_action_sets before vim.iter:", t_action_sets)

                for i, action in ipairs(t_action_sets) do
                    if
                        not vim.iter(action):all(function(k, v)
                            -- This is not bulletproof!
                            return v.target_module_dir:match("nvim/lua/doom/modules")
                                or v.target_module_dir:match("nvim/lua/user/modules")
                        end)
                    then
                        -- log.info("manage_modules_tree > Validate input: Some action were invalid OR not doom modules.")
                        log.error(
                            "ABORT: Dui module browser: target file is not a doom-nvim lua file"
                        )
                        return
                    end
                    -- TODO: if the input already has init file then ignore
                    --
                    -- add init files
                    vim.iter(action)
                        :map(function(entry)
                            -- TODO:
                            -- entry.enabled ?? i dont think this is necessary.

                            -- TODO: need to check this in the path tree.
                            -- entry.origin = ???

                            entry.path_init_file = (entry.target_module_dir / "init.lua"):tostring()
                            entry.t_path = mu.get_module_t_path_from_init_path(node.path_init_file)
                            entry.section =
                                table.concat(table.remove(vim.deepcopy(entry.t_path)), ".") -- remove the name..
                            return entry
                        end)
                        :totable()

                    -- for i, v in ipairs(t_action_sets[i]) do
                    --   print(">>>", v[1].)
                    -- end
                end

                log.warn("t_action_sets after vim.iter:", t_action_sets)

                -- require("doom.modules.features.dui.modules_manager").manage_modules_tree(t_action_sets)
            end
        )
    end

    ---Recursive modules browser implemented with vim.ui.select()
    ---@param path_in string|nil: The dir that you wish to start from or doom modules base dir.
    local function modules_browser(path_in)
        local current_dir = Path(path_in or require("doom.core.system").doom_modules_path())
        -- log.info("current dir:", current_dir)
        local possible_choices = {
            current_dir,
        }
        for path in current_dir:iterdir({ depth = 1 }) do
            if path:is_dir() then
                table.insert(possible_choices, path)
            end
        end
        -- log.info("possible_choices", possible_choices)
        vim.ui.select(
            possible_choices,
            -- options
            {
                prompt = string.format("[MODULES BROWSER](../%s/..)", current_dir:basename()),
                format_item = function(item)
                    if item == current_dir then
                        return string.format("current = %s", current_dir:basename())
                    elseif type(item) == "table" then
                        local is_module = false
                        for path in item:iterdir({ depth = 1 }) do
                            if path:match("init.lua$") then
                                is_module = true
                            end
                        end
                        return string.format(
                            "%s -> %s",
                            is_module and "mod" or "dir",
                            item:basename()
                        )
                    end
                end,
            },
            -- on_choice actions
            function(choice)
                -- TODO: Can I add keybind to toggle enabled here?
                -- Or do I need to migrate to a real picker?

                if not choice then
                    return -- eg. <esc>
                end
                if choice == current_dir then
                    mod_browser_operate_on_current_dir(choice)
                else
                    local is_module = false
                    for path in choice:iterdir({ depth = 1 }) do
                        if path:match("init.lua$") then
                            is_module = true
                        end
                    end
                    if is_module then
                        vim.cmd(string.format("edit %s", choice / "init.lua"))
                    else
                        modules_browser(choice)
                    end
                end
            end
        )
    end

    -- main
    modules_browser()
end

return __modules_browser_wrap
