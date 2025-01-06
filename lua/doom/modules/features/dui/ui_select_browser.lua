local log = require("doom.utils.logging")

-- TODO: I need to visually make dirs vs mod become much clearer
--
-- TODO: Include user modules.
--
-- TODO: If <CR> on `current` for dir AND no custom name string
-- has bee provided, then prompt user for a new module name.
--
-- migrate this to telescope?
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

                local split_on_whitespace = vim.split(module_target_name, " ")
                local move_to_destination
                if #split_on_whitespace > 1 then
                    module_target_name = split_on_whitespace[1]
                    move_to_destination = split_on_whitespace[2]
                end

                -- Check action remove
                local action = module_target_name:match("^%-") and "REMOVE"
                if action == "REMOVE" then
                    module_target_name = module_target_name:sub(2)
                end

                if move_to_destination then
                    action = "MOVE"
                end

                if not action then
                    action = "ADD"
                end

                -- Validate | Do both src and dest?
                if module_target_name:match("[^%a_]") then
                    log.error("!! INVALID MODULE TARGET STRING !!")
                    return
                end

                local target_module_dir = path_to / module_target_name

                -- everything in manager should go into the manager file.
                require("doom.modules.features.dui.modules_manager").manage_modules_tree({
                    targets = { {
                        target_module_name = module_target_name,
                        target_module_dir = target_module_dir,
                    } },
                    action = action,
                })

                -- if
                --     not (
                --         target_module_dir:match("nvim/lua/doom/modules")
                --         or target_module_dir:match("nvim/lua/user/modules")
                --     )
                -- then
                --     log.error("ABORT: Dui module browser: target file is not a doom-nvim lua file")
                --     return
                -- end
                --
                -- -- Handle modules.lua
                -- transform_enabled_modules_tree(target_module_init_file, action)
                --
                -- -- Create new module/init file
                -- if not target_module_init_file:exists() then
                --     local ok = target_module_init_file:touch(Path.permission("rw-r--r--"), true)
                --     if ok then
                --         -- add contents template
                --         local pu = require("doom.modules.features.dui.templates")
                --
                --         -- sync method
                --         local file = io.open(target_module_init_file:tostring(), "w+")
                --         if file then
                --             file:write(pu.gen_temp_from_mod_name(module_target_name))
                --             file:close()
                --             vim.cmd(string.format("edit %s", target_module_init_file))
                --         end
                --
                --         -- -- async method
                --         -- local nio = require("nio")
                --         -- local future = nio.control.future()
                --         -- fs.write_file(
                --         --     target_module_init_file:tostring(),
                --         --     pu.gen_temp_from_mod_name(module_target_name),
                --         --     "w+",
                --         --     function()
                --         --         future.set(true)
                --         --     end
                --         -- )
                --         -- future.wait()
                --         -- vim.cmd(string.format("edit %s", target_module_init_file))
                --
                --     end
                --     log.info(("DUI :: Created new module: %s"):format(target_module_init_file))
                -- elseif action == "REMOVE" then
                --     log.info("DUI: Removing dir:", target_module_dir)
                --     fs.rm_dir(target_module_dir:tostring())
                -- end
                --
                -- -- Reload
                -- if false then
                --     doom.modules.core.reloader.reload()
                -- end
            end
        )
    end

    ---Recursive modules browser implemented with vim.ui.select()
    ---@param path_in string|nil: The dir that you wish to start from or doom modules base dir.
    local function modules_browser(path_in)
        local current_dir = Path(path_in or require("doom.core.system").doom_modules_path())
        local possible_choices = {
            current_dir,
        }
        for path in current_dir:iterdir({ depth = 1 }) do
            if path:is_dir() then
                table.insert(possible_choices, path)
            end
        end
        vim.ui.select(possible_choices, {
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
                    return string.format("%s -> %s", is_module and "mod" or "dir", item:basename())
                end
            end,
        }, function(choice)
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
        end)
    end

    -- main
    modules_browser()
end

return __modules_browser_wrap
