local dorothy = {}

--------------------------------------------

-- TODO: dorothy menu
-- ~ new source user
-- ~ new source user local
-- ~ new command user
-- ~ new command user local

-- TODO: cmd gh clone/fork plugin into dorothy `ghm` management.

-- TODO: autocmds for auto formatting and running tests and shit.
-- 1. command for autocmd watch changes and run dry run test.
-- 2. run tests on dorothy command that just had a change.
--    ~ edit `choose` command.
--    ~ run tests for choose.
--    ~ edit other file.
--    ~ run tests for other file.
--    >> spit everything out to a specific dorothy log file.
--    if there were any errors -> run notifier in nvim.

-- HACK: DOROTHY MONITORS: if editing a dorothy command, then try running the tests and put
-- it in the `dorothy_tests` output buffer, and then prep the buffer with
-- a nice header.

-- TODO:
--  - if ! --shell flag then prompt with a selection
--    menu for possible shells, eg. bash or nvim
--

-- TODO: make a picker that merges commands / sources / whatever between
-- doothy and user for when searching.
--
-- TODO: picker for local files only??

--------------------------------------------

-- ---------
-- -- autoformat dorothy on save.
-- dorothy.autocommands = {
--   -- {
--   --   "ColorScheme",
--   --   "*",
--   --   function()
--   --     print("colorscheme update")
--   --     print(vim.inspect(require('heirline').statusline))
--   --     -- doom.modules.features.statusline2.configs["heirline.nvim"]()
--   --   end,
--   -- },
--   -- {
--   -- user
--   --  - auto commit on change?
--   --  -> qhq / tmux / other??
--   -- }
-- }

-- TODO:
--  1. create new command in split to the right
--  2. hidden command
--  3. add new command to core
--    run dorothy add file command and get file path returned.

-- -- todo: redo this with core/sys path
-- local mod_glob_path = function(origin)
--   return string.format("%s/lua/%s/modules/**/init.lua", vim.fn.stdpath("config"), origin)
-- end
--
-- local function m_glob(cat)
--   if vim.tbl_contains(spec.origins, cat) then
--     return vim.split(vim.fn.glob(mod_glob_path(cat)), "\n")
--   end
-- end

local dorothy_dir = os.getenv("DOROTHY")

local commands_public = {
    dorothy_dir .. "/commands",
    dorothy_dir .. "/commands.beta",
    dorothy_dir .. "/user/commands",
}

-- TODO: just put all dorothy files in one big picker.

-- Get dirs with private files from pattern match dirs.
-- local private_files = {
--     dorothy_dir .. "/user/commands.local",
-- }

local sources = {
    dorothy_dir .. "/sources",
    dorothy_dir .. "/config",
    dorothy_dir .. "/user/sources",
    dorothy_dir .. "/user/config",
}

local function search_dorothy_cmds()
    local make_entry = require("telescope.make_entry")
    require("telescope.builtin").find_files({
        prompt_title = "Dorothy Commands",
        entry_maker = function(entry)
            local res = entry:match("dorothy/(.*)")
            return {
                value = entry,
                display = res,
                ordinal = res,
            }
        end,
        search_dirs = commands_public,
    })
end

local function search_dorothy_sources()
    local make_entry = require("telescope.make_entry")
    require("telescope.builtin").find_files({
        prompt_title = "Dorothy Sources",
        entry_maker = function(entry)
            local res = entry:match("dorothy/(.*)")
            return {
                value = entry,
                display = res,
                ordinal = res,
            }
        end,
        search_dirs = sources,
    })
end

-- FIX: reuse same entry makes for grepping

local function grep_dorothy()
    require("telescope.builtin").live_grep({
        prompt_title = "Dorothy Grep",
        search_dirs = { dorothy_dir, dorothy_dir .. "/user" },
    })
end
local function add_package_to_user_setup()
    -- create a UI that allows one to add a package name string to a new
    -- array in users setup.bash file.
    --
    -- maybe i could also reuse some of the existing dorothy config funcs
    -- here
    --
end
dorothy.binds = {
    "<leader>",
    name = "+prefix",
    {
        "<leader>",
        name = "+prefix",
        {
            "d",
            name = "+debug", -- dorothy
            {
                "a",
                name = "+ayo",
                {
                    {
                        "c",
                        name = "search dorothy commands",
                        function()
                            search_dorothy_cmds()
                        end,
                    },
                    {
                        "s",
                        name = "search dorothy sources",
                        function()
                            search_dorothy_sources()
                        end,
                    }, -- user command
                    {
                        "w",
                        name = "Grep Dorothy",
                        function()
                            grep_dorothy()
                        end,
                    },
                    {
                        "p",
                        function()
                            -- eg brew -> wezterm
                            add_package_to_user_setup()
                        end,
                        name = "dorothy add package",
                    },
                    -- { "m" }, -- user command minimal
                    -- { "d" }, -- user command.local
                    -- { "h" }, -- user config
                    -- { "h" }, -- user config.local
                    -- { "h" }, -- user source
                    -- -- { "h" }, -- user source.local ???
                    -- { "h" }, -- core command
                    -- { "h" }, -- core source
                    -- { "h" }, -- core config
                },
            },
        },
    },
}

return dorothy
