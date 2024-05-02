-- Just override stuff in the `doom` global table (it's injected into scope
-- automatically).
local utils = require("doom.utils")
local is_module_enabled = utils.is_module_enabled
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local system = require("doom.core.system")

-- network resource manager | https://github.com/miversen33/netman.nvim

-- https://github.com/David-Kunz/gen.nvim

-- NOTE: https://github.com/zeioth/heirline-components.nvim

-- key logging / heatmap: https://github.com/glottologist/keylog.nvim

-- NOTE: https://github.com/616b2f/bsp.nvim

-- WARN: https://github.com/roobert
-- This guy has made some seriously cool plugins

-- NOTE: Add new module command.
-- Command/bind ->
--     Select dir for new module -> Use vim.ui input
--         if you type a string and hit enter -> try create module at current dir/level.
--             create new dir
--                 create new file
--                    i.  Add MODULE to `./modules.lua`
--                    ii. Open new file in current window
--                            >> initialize `doom_new_module` snippet.

-- NOTE: redirect print output into eg. clipboard
-- When I use lua to print something, it shows it in the bottom bar, how do I copy all contents of it?
-- I know that using g< will show it to me againn but how would I redirect it to a clipboard
-- justlinuxuser
-- nvm, I just used a tempfile to dump my stdout
-- justinmk
-- can use :redir @+ . but eventually we should make this easier
-- or :let @+=execute('...')

-- => GREAT LIST OF NVIM PLUGINS: https://yutkat.github.io/my-neovim-pluginlist/

-- ~ ZIONTEE:
--     https://github.com/ziontee113/syntax-tree-surfer
--     https://github.com/ziontee113/deliberate.nvim
--     >>> ziontee's ts plugins are getting really fucking good now.
-- !!! https://github.com/nvim-telescope/telescope-live-grep-args.nvim

-- TODO: extend neorg workspaces here with my own ones!!!

-- TODO: file explorer -> oil.nvim plugin seems super awesome
--
-- TODO: winbar -> Bekaboo/dropbar.nvim

-- BINDING: Nui input ( path ) -> telescope grep ( path )

-- TODO: auto close buffers above threshold
-- https://github.com/axkirillov/hbac.nvim

-- vim.cmd([[ :TransparentEnable ]])

-- packer.nvim logs to stdpath(cache)/packer.nvim.log. Looking at this file is usually a good start if something isn't working as expected.

-- doom.settings.cmp_binds = {
--   select_prev_item = "<C-p>",
--   select_next_item = "<C-n>",
--   scroll_docs_fwd = "<C-d>",
--   scroll_docs_bkw = "<C-f>",
--   complete = "<C-Space>",
--   close = "<C-h>",
--   confirm = "<C-a>",
--   tab = "<C-l>",
--   stab = "<C-h>",
-- }

doom.settings.local_plugins_path = "~/code/repos/github.com"
doom.settings.using_ghq = true

---------------------------
---       GLOBALS       ---
---------------------------

local ok, plenary_reload = pcall(require, "plenary.reload")
local reloader = require
if ok then
  reloader = plenary_reload.reload_module
end

P = function(data, depth, prefix_str)
  local pre = prefix_str or ""
  if depth then
    print(pre, vim.inspect(data, { depth = depth }))
  else
    print(pre, vim.inspect(data))
  end
  return data
end

-- TODO: bind P( viw / viW )
-- funcs.inspect_visual_sel = function()
--   vim.inspect(funcs.get_visual_selection())
-- end

-- P("arst")

GGG = function(depth)
  local t = {}
  depth = depth or 1
  for k, v in pairs(_G) do
    if k:match("^_doom") then
      t[k] = v
    end
  end
  print("inspect `_doom`", vim.inspect(t, { depth = depth }))
end

D = function(v, pre)
  log.debug(pre or "", v)
end

RELOAD = function(...)
  return reloader(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

--------------------------
---       KEYMAP       ---
--------------------------

-- NOTE: Issue with keymap not being applied in select mode.

vim.opt.keymap = "INSERT_COLEMAK"

---------------------------------
---       DOOM SETTINGS       ---
---------------------------------

doom.core.treesitter.settings.show_compiler_warning_message = false

-- doom.core.reloader.settings.reload_on_save = true

-- vim.opt.guifont = { 'Hack Nerd Font', 'h12' }
-- Editor config
-- doom.border_style = { "", "", "", "", "", "", "", "" }
-- doom.impatient_enabled = true

--   · trace
--   · debug
--   · info
--   · warn
--   · error
--   · fatal
doom.settings.logging = "warn"

---------------------------
---       OPTIONS       ---
---------------------------

vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.winwidth = 95
vim.opt.scrolloff = 16
vim.opt.virtualedit = "block" -- allow vis block to reach EOL for all lines
vim.opt.ignorecase = true -- autocomplete eg `neor` -> Neorg

-- -- test add local plugin
-- -- ':lua vim.opt.runtimepath:append("~/code/plugins/nvim/lookup.nvim")',
-- 'set keymap=INSERT_COLEMAK',
-- 'set iminsert=1',
-- 'set imsearch=0',
-- 'let g:surround_no_mappings=1',
-- 'set grepprg=rg\\ --vimgrep\\ --no-heading\\ --smart-case',
-- 'set grepformat=%f:%l:%c:%m',
-- -- 'set noexrc',
-- -- 'set noex',
-- -- -- 'set nosecure',
-- -- 'set ruler',
-- -- 'set autoread',
-- -- 'set laststatus=2',
-- -- 'set splitright',
-- -- 'set splitbelow',
-- -- 'set sidescrolloff=15',
-- -- 'set sidescroll=5',
-- -- 'set equalalways',
-- -- 'set smarttab',
-- -- 'set autoindent',
-- -- 'set cindent',
-- -- 'set smartcase',
-- -- 'set ignorecase',
-- -- 'set showmatch',
-- -- 'set incsearch',
-- -- 'set cmdheight=1',
-- -- 'set showcmd',
-- -- 'set pumblend=17',
-- -- 'set updatetime=1000',
-- -- -- 'set hlsearch',
-- -- 'set breakindent',
-- -- 'set foldmethod=indent',
-- -- 'set linebreak',
-- -- 'set visualbell',
-- -- -- 'set belloff',
-- -- 'set inccommand=split',
-- -- 'set nojoinspaces',
-- -- -- 'set fillchars={ 'eob' = "~" }',

vim.opt.guifont = { "Hack Nerd Font", "h12" }

-- Editor config
doom.settings.indent = 2

doom.settings.escape_sequences = { "zm" }

-- vim.lsp.set_log_level('info')
vim.diagnostic.config({
  float = {
    source = "always",
  },
})

--
-- TABS
--

if doom.modules.tabline then
  doom.modules.tabline.settings.options.diagnostics_indicator = function(_, _, diagnostics_dict, _)
    doom.modules.tabline.settings.options.numbers = nil -- Hide buffer numbers
    local s = ""
    for e, _ in pairs(diagnostics_dict) do
      local sym = e == "error" and " " or (e == "warning" and " " or " ")
      s = s .. sym
    end
    return s
  end
end

-------------------------------------
---       CURSOR LINE / COL       ---
-------------------------------------

-- TODO: add my own custom colors to cursor line and
--        also add cursor col so that it is easier to locate the cursor.

---------------------------
---       HELPERS       ---
---------------------------

-- move these into utils.

local funcs = {}

-- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601/2
-- https://github.com/kristijanhusak/neovim-config/blob/master/nvim/lua/partials/search.lua
-- TODO: move to utils??
funcs.get_visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end

-- -- open buffer and read feat req template so that one can quickly
-- -- document
-- -- NOTE: I was testing here how to insert text from lua variable
-- funcs.create_feat_request = function()
--   vim.cmd([[ :vert new ]])
--   vim.cmd("read " .. system.doom_root .. "/templates/skeleton_feat_request.md")
--   local bufnr = vim.api.nvim_get_current_buf()
--   vim.api.nvim_buf_set_text(bufnr, 5, 0, 5, 0, utils.str_2_table(get_system_info_string(), "\n"))
-- end
--
-- -- open empty buffer and read crash report so that an issue can be
-- -- documented fast when it occurs
-- funcs.report_an_issue = function()
--   -- functions.create_report()
--   create_report()
--   vim.cmd([[ :vert new ]])
--   -- print(system.doom_report)
--   vim.cmd("read " .. system.doom_report)
-- end
--
------------------------------
---       COMPLETION       ---
------------------------------

-- sources
-- TODO: add all of my custom sources here or in a special module where I
-- handle all of my personal cmp additions
-- https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources

-- menu appearance
-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance

-- advanced techniques
-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques

doom.settings.mappings.cmp = {
  select_prev_item = "<C-p>",
  select_next_item = "<C-n>",
  scroll_docs_fwd = "<C-d>",
  scroll_docs_bkw = "<C-f>",
  complete = "<C-Space>",
  close = "<C-e>",
  confirm = "<C-l>",
  tab = "<Tab>",
  stab = "<S-Tab>",
}

-- TODO: CUSTOMIZE SNIPPET BINDS

-- doom.settings.mappings.luasnip = {
--   next_choice = "",
--   prev_choice = "",
-- }

-----------------------
---       LSP       ---
-----------------------

-- TODO: try some stuff here.
--
--  - learn how customizing handlers work.

-- vim.lsp.set_log_level('trace')

--
-- LINTING
--

-- doom.modules.linter.settings.format_on_save = true

-------------------------------
---       DIAGNOSTICS       ---
-------------------------------

vim.diagnostic.config({
  float = {
    source = "always",
  },
})

---------------------------
---       TABLINE       ---
---------------------------

if doom.modules.tabline then
  doom.modules.tabline.settings.options.diagnostics_indicator = function(_, _, diagnostics_dict, _)
    doom.modules.tabline.settings.options.numbers = nil -- Hide buffer numbers
    local s = ""
    for e, _ in pairs(diagnostics_dict) do
      local sym = e == "error" and " " or (e == "warning" and " " or " ")
      s = s .. sym
    end
    return s
  end
end

--------------------------
---       COLORS       ---
--------------------------

-- doom.use_package("sainnhe/sonokai", "EdenEast/nightfox.nvim")
--
-- local options = {
--   dim_inactive = true,
-- }
-- local palettes = {
--   dawnfox = {
--     bg2 = "#F9EFEC",
--     bg3 = "#ECE3DE",
--     sel1 = "#EEF1F1",
--     sel2 = "#D8DDDD",
--   },
-- }
-- local specs = {}
-- local all = {
--   TelescopeNormal = { fg = "fg0", bg = "bg0" },
--   TelescopePromptTitle = { fg = "pallet.green", bg = "bg1" },
--   TelescopePromptBorder = { fg = "bg1", bg = "bg1" },
--   TelescopePromptNormal = { fg = "fg1", bg = "bg1" },
--   TelescopePromptPrefix = { fg = "fg1", bg = "bg1" },
--
--   TelescopeResultsTitle = { fg = "pallet.green", bg = "bg2" },
--   TelescopeResultsBorder = { fg = "bg2", bg = "bg2" },
--   TelescopeResultsNormal = { fg = "fg1", bg = "bg2" },
--
--   TelescopePreviewTitle = { fg = "pallet.green", bg = "bg1" },
--   TelescopePreviewNormal = { bg = "bg1" },
--   TelescopePreviewBorder = { fg = "bg1", bg = "bg1" },
--   TelescopeMatching = { fg = "error" },
--   CursorLine = { bg = "sel1", link = "" },
-- }
--
-- require("nightfox").setup({
--   options = options,
--   palettes = palettes,
--   specs = specs,
--   all = all,
-- })

doom.settings.colorscheme = "tokyonight"

--
-- Extra packages
--

-- doom.use_package(
--   "rafcamlet/nvim-luapad",
--   "nvim-treesitter/playground",
--   -- "tpope/vim-surround",
--   "dstein64/vim-startuptime"
-- )

-- doom.langs.lua.packages["lua-dev.nvim"] = { "max397574/lua-dev.nvim", ft = "lua" }

vim.opt.guifont = { "Hack Nerd Font", "h12" }

vim.cmd("let g:neovide_refresh_rate=60")
vim.cmd("let g:neovide_cursor_animation_length=0.03")
vim.cmd("set laststatus=3")

--
-- TELESCOPE
--

local telescope_defaults = doom.modules.features.telescope.settings.defaults

telescope_defaults.layout_config.width = 0.95
telescope_defaults.layout_config.horizontal.mirror = true
telescope_defaults.layout_config.horizontal.preview_width = 0.45
telescope_defaults.winblend = 10

--
-- WHICHKEY
--

--
-- TREESITTER
--

-- TS CONTEXT
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "DarkMagenta" })
-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { bg="Pink" })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { bg = "SeaGreen", underline = true })

-- test add doom module

local function new_module()
  -- TODO: make recursive
  -- 1. core/user
  -- 2. initialize with `modules dir`
  -- 3. check if sub dirs can have
  -- 4. create module for final selection

  -- Ie. without `init.lua` file.
  local function find_sub_dirs() end

  local function initialize_new_module() end

  local mp = require("doom.core.system").doom_modules_path()
  local Path = require("pathlib")
  mp = Path(mp)

  local possible_choices = {
    ".",
  }

  for path in mp:iterdir({ depth = 1 }) do
    if path:is_dir() then
      print(path:basename())
      table.insert(possible_choices, path)
    end
  end

  vim.ui.select(possible_choices, {
    prompt = "Select dir for new module:",
    format_item = function(item)
      if item == "." then
        return "[current dir]"
      elseif type(item) == "table" then
        return "dir -> " .. item:basename()
      end
    end,
  }, function(choice)
    print("choice =", choice)
  end)
end

doom.use_keybind({
  {
    "<leader>D",
    name = "+doom",
    {
      {
        "M",
        function()
          new_module()
        end,
        name = "testing",
      },
    },
  },
})

-- vim: sw=2 sts=2 ts=2 expandtab
