local dorothy = {}

--------------------------------------------

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

-- Get dirs with private files from pattern match dirs.
-- local private_files = {
--     dorothy_dir .. "/user/commands.local",
-- }

local sources = {
  dorothy_dir .. "/sources",
  dorothy_dir .. "/user/sources",
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
    search_dirs = {
      dorothy_dir .. "/commands",
      dorothy_dir .. "/commands.beta",
      dorothy_dir .. "/user/commands",
    },
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
    search_dirs = {
      dorothy_dir .. "/sources",
      dorothy_dir .. "/user/sources",
    },
  })
end

local function grep_dorothy()
  require("telescope.builtin").live_grep({
    prompt_title = "Dorothy Grep",
    search_dirs = { dorothy_dir, dorothy_dir .. "/user" },
  })
end

dorothy.binds = {
  "<leader>",
  name = "+prefix",
  {
    "<leader>",
    name = "+prefix",
    {
      "d",
      name = "+debug",       -- dorothy
      {
        "a",
        name = "+add_file",
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
          },           -- user command
          {
            "w",
            name = "Grep Dorothy",
            function()
              grep_dorothy()
            end,
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
