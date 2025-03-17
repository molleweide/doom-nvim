--  doom.core.config
--
--  Responsible for setting some vim global defaults, managing the `doom.field_name`
--  config options, pre-configuring the user's modules from `modules.lua`, and
--  running the user's `config.lua` file.

local log = require("doom.utils.logging")
local profiler = require("doom.services.profiler")
local utils = require("doom.utils")
local system = require("doom.core.system")
-- local mod_utils = require("doom.utils.modules")
-- local tree = require("doom.utils.tree")
local config = {}
local filename = "config.lua"

config.source = nil

-- Load module and attach it to the [doom] table.
-- Currently the [node] arg is only used to check
config.attach_module = function(t_path)
    local path_module = table.concat(t_path, ".")

    -- profile each module
    local profiler_message = ("modules|import `%s`"):format(path_module)
    profiler.start(profiler_message)

    local ok, result
    local correct_path
    for _, path in ipairs(system.get_mod_search_paths(path_module)) do
        ok, result = xpcall(require, debug.traceback, path)
        if ok then
            correct_path = path
            break
        end
    end

    if ok then
        -- empty module
        if type(result) == "boolean" and result then
            log.debug(
                string.format(
                    "'%s' is an empty module that returned nothing. Ignoring...",
                    path_module
                )
            )
        else
            -- valid non empty module

            -- Attach additional meta data.
            result.origin = correct_path:match("^(%w-)%.")
            result.type = "doom_module_single"
            result.name = correct_path
            result.enabled = true

            utils.get_set_table_path(doom.modules, t_path, result)

            -- Needs to be attached to custom table since each package is unaware
            -- of its respective doom module.
            if result.package_reloaders then
                for k, v in pairs(result.package_reloaders) do
                    doom.package_reloaders[k] = v
                end
            end
        end
    else
        -- bad module
        log.error(
            string.format(
                "There was an error loading module '%s'. Traceback:\n%s",
                path_module,
                result
            )
        )
        -- log.error(string.format("There was an error loading module '%s'", path_module))
    end

    profiler.stop(profiler_message)
end

--- Entry point to bootstrap doom-nvim.
config.load = function()
    -- Set vim defaults on first load. To override these, the user can just
    -- override vim.opt in their own config, no bells or whistles attached.
    vim.opt.hidden = true
    vim.opt.updatetime = 200
    vim.opt.timeoutlen = 400
    vim.opt.background = "dark"
    vim.opt.completeopt = {
        "menu",
        "menuone",
        "preview",
        "noinsert",
        "noselect",
    }
    vim.opt.shortmess = "atsc"
    vim.opt.inccommand = "split"
    vim.opt.path = "**"
    vim.opt.signcolumn = "auto:2-3"
    vim.opt.foldcolumn = "auto:9"
    vim.opt.formatoptions:append("j")
    vim.opt.fillchars = {
        vert = "▕",
        fold = " ",
        eob = " ",
        diff = "─",
        msgsep = "‾",
        foldopen = "▾",
        foldclose = "▸",
        foldsep = "│",
    }
    vim.opt.smartindent = true
    vim.opt.copyindent = true
    vim.opt.preserveindent = true
    vim.opt.cursorline = true
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.scrolloff = 4
    vim.opt.showmode = false
    vim.opt.mouse = "a"
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.expandtab = true
    vim.opt.conceallevel = 0
    vim.opt.foldenable = true
    vim.opt.foldtext = require("doom.core.functions").sugar_folds()

    -------------------------------------------------------------------
    -- Load modules | Based on their [enabled] and [tag] attributes. --
    -------------------------------------------------------------------

    profiler.start("framework|import modules")

    local modules_ok, enabled_modules = require("doom.core.modules").enabled_modules()

    -- log.info(vim.inspect(enabled_modules))

    local DOOM_STARTUP_MODE = os.getenv("DOOM_STARTUP_MODE")
    local DOOM_LOAD_SECTIONS = os.getenv("DOOM_LOAD_SECTIONS")
    local DOOM_LOAD_TAGS = os.getenv("DOOM_LOAD_TAGS")

    print(string.format(
        [[ ENV VARS:
                startup = %s
                sections = %s
                tags = %s
                _doom_first_load = %s
            ]],
        DOOM_STARTUP_MODE,
        DOOM_LOAD_SECTIONS,
        DOOM_LOAD_TAGS,
        _doom_first_load
    ))

    -- TODO: ( ) Handle DOOM_STARTUP_MODE
    -- if "first load and startup mode env var" then
    --     -- override DOOM_LOAD_SECTIONS and DOOM_LOAD_TAGS with predefined presets
    --     print(arst)
    -- end

    -- if modules_ok then...
    if not modules_ok then
        log.error("[core.config] > There was an error loading enabled [modules.lua] table.")
    else
        -- handle modules declared as <tables> and also <strings> for backwards compatability.
        local check_is_module = function(node, stack)
            local parent = stack[#stack]
            if
                (type(node) == "string") -- string module
                or (parent and type(parent.key) == "number" and type(node) == "table") -- table module
            then
                return true
            end
        end

        -- returns true if a module should not be loaded.
        local filter_module_declaration = function(check_filter_str, compare)
            local is_inclusive = check_filter_str:match("^!"):sub(2)
            local t_filter = vim.split(check_filter_str, ".")
            if type(check_filter_str) == "string" then
                for _, compare_str in ipairs(type(compare) == "string" and { compare } or compare) do
                    local match = vim.tbl_contains(t_filter, compare_str)
                    if is_inclusive and not match then
                        return true
                    end
                    if not is_inclusive and match then
                        return true
                    end
                end
            end
        end

        -- TODO: Rename `node` to `module_declaration`

        -- TODO: Currently, modules, can only be strings, >>> Need to change
        -- this so that one can supply a module table instead.

        -- Combine enabled modules (`modules.lua`) with core modules.
        require("doom.utils.modules").traverse_enabled(enabled_modules, function(node, stack)
            if check_is_module(node, stack) then
                -- if type(node) == "table" then
                --     return
                -- end

                -- TODO: ( ) handle both old and new way
                -- put together path
                local t_path = vim.tbl_map(function(stack_node)
                    -- print(string.format("[stack node]: %s", vim.inspect(stack_node)))
                    return type(stack_node.key) == "string" and stack_node.key:lower()
                        -- table declaration
                        or type(stack_node) == "table" and stack_node.node[1]
                        -- single string declaration
                        or stack_node.node
                end, stack)

                -- print(vim.inspect(t_path))

                local path_module = table.concat(t_path, ".")

                -- print("path: ", path_module)

                ---------------------------------------------------------
                -- filter modules
                ---------------------------------------------------------
                --
                -- TODO: Later, move this into meta __eq operator on the doom table
                -- itself. So that it can be reused in other settigs.

                -- check if enabled or backwards compatible "string"
                if not (type(node) == "string" or node.enabled) then
                    return
                end

                -- only load by env vars if it is the first time.
                if false and _doom.first_load then
                    -- make lower case and trim the module name from the string
                    if
                        DOOM_LOAD_SECTIONS
                        and filter_module_declaration(
                            DOOM_LOAD_SECTIONS,
                            table.concat(t_path, "."):lower():gsub("%.[^%.]+$", "")
                        )
                    then
                        return
                    end
                    if
                        DOOM_LOAD_TAGS
                        and filter_module_declaration(DOOM_LOAD_TAGS, node.tags or {})
                    then
                        return
                    end
                end

                ---------------------------------------------------------
                -- load and attach module to [doom]
                ---------------------------------------------------------

                config.attach_module(t_path)
            end
        end, { name = "[ core/config ]: traverse enabled_modules" })
    end

    profiler.stop("framework|import modules")

    profiler.start("framework|config.lua (user)")

    --
    -- Execute user's root [config.lua] file so they can modify the doom global
    -- object.
    --

    local ok, err = xpcall(dofile, debug.traceback, config.source)
    local log = require("doom.utils.logging")
    if not ok and err then
        log.error("[core/config.lua]: Error while running `config.lua`. Traceback:\n" .. err)
    end
    profiler.stop("framework|config.lua (user)")

    --
    -- Apply additonal necessary [doom.field_name] options
    --

    vim.opt.shiftwidth = doom.settings.indent
    vim.opt.softtabstop = doom.settings.indent
    vim.opt.tabstop = doom.settings.indent
    if doom.settings.guicolors then
        if vim.fn.exists("+termguicolors") == 1 then
            vim.opt.termguicolors = true
        elseif vim.fn.exists("+guicolors") == 1 then
            vim.opt.guicolors = true
        end
    end

    if doom.settings.auto_comment then
        vim.opt.formatoptions:append("croj")
    end
    if doom.settings.movement_wrap then
        vim.cmd("set whichwrap+=<,>,[,],h,l")
    end

    if doom.settings.undo_dir then
        vim.opt.undofile = true
        vim.opt.undodir = doom.settings.undo_dir
    else
        vim.opt.undofile = false
        vim.opt.undodir = nil
    end

    if doom.settings.global_statusline then
        vim.opt.laststatus = 3
    end

    -- Use system clipboard
    if doom.settings.clipboard then
        vim.opt.clipboard = "unnamedplus"
    end

    if doom.settings.ignorecase then
        vim.cmd("set ignorecase")
    else
        vim.cmd("set noignorecase")
    end
    if doom.settings.smartcase then
        vim.cmd("set smartcase")
    else
        vim.cmd("set nosmartcase")
    end

    -- Color column
    vim.opt.colorcolumn = type(doom.settings.max_columns) == "number"
            and tostring(doom.settings.max_columns)
        or ""

    -- Number column
    vim.opt.number = not doom.settings.disable_numbering
    vim.opt.relativenumber = not doom.settings.disable_numbering and doom.settings.relative_num

    vim.g.mapleader = doom.settings.leader_key
end

-- Path cases:
--   1. stdpath('config')/../doom-nvim/config.lua
--   2. stdpath('config')/config.lua
--   3. <runtimepath>/doom-nvim/config.lua
config.source = utils.find_config(filename)

return config
