-- Just override stuff in the `doom` global table (it's injected into scope
-- automatically).
local utils = require("doom.utils")
local is_module_enabled = utils.is_module_enabled
local log = require("doom.utils.logging")
local fs = require("doom.utils.fs")
local system = require("doom.core.system")

doom.moll = {}

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

--------------------------
---       KEYMAP       ---
--------------------------

local colemakdh = [[
" Hjalmar Jakobsson
" COLEMAK keymap
" for insert mode
let b:keymap_name = "INSERT_COLEMAK"

loadkeymap
a a
b v
c c
d s
e f
f t
g g
h k
i u
j n
k e
l i
m h
n m
o y
p ;
q q
r p
s r
t b
u l
v d
w w
x x
y j
z z
; o

A A
B V
C C
D S
E F
F T
G G
H K
I U
J N
K E
L I
M H
N M
O Y
P :
  Q Q
  R P
  S R
  T B
  U L
  V D
  W W
  X X
  Y J
  Z Z
: O
]]

vim.opt.keymap = "INSERT_COLEMAK"

---------------------------
---       OPTIONS       ---
---------------------------

vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true

--   · trace
--   · debug
--   · info
--   · warn
--   · error
--   · fatal
-- doom.settings.logging = "error"

vim.opt.winwidth = 95

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

---------------------------
---       HELPERS       ---
---------------------------

-- move these into utils.

function i(x, pre)
  print(pre or "", vim.inspect(x))
end

local funcs = {}

funcs.inspect = function(v)
  print(vim.inspect(v))
  return v
end

-- https://neovim.discourse.group/t/function-that-return-visually-selected-text/1601/2
-- https://github.com/kristijanhusak/neovim-config/blob/master/nvim/lua/partials/search.lua

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

funcs.inspect_visual_sel = function()
  vim.inspect(funcs.get_visual_selection())
end

-- open buffer and read feat req template so that one can quickly
-- document
-- NOTE: I was testing here how to insert text from lua variable
funcs.create_feat_request = function()
  vim.cmd([[ :vert new ]])
  vim.cmd("read " .. system.doom_root .. "/templates/skeleton_feat_request.md")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_text(bufnr, 5, 0, 5, 0, utils.str_2_table(get_system_info_string(), "\n"))
end

-- open empty buffer and read crash report so that an issue can be
-- documented fast when it occurs
funcs.report_an_issue = function()
  -- functions.create_report()
  create_report()
  vim.cmd([[ :vert new ]])
  -- print(system.doom_report)
  vim.cmd("read " .. system.doom_report)
end

-- funcs.checkPackagesNil = function()
--   local c = 0
--   for k, v in pairs(doom.packages) do
--     if k == nil then
--       print("c", c)
--       c = c + 1
--     end
--   end
--     -- print("xxx")
-- end

doom.moll.funcs = funcs

---------------------------
---------------------------
---       PLUGINS       ---
---------------------------
---------------------------

doom.settings.colorscheme = "tokyonight"

-- vim.opt.guifont = { 'Hack Nerd Font', 'h12' }
-- Editor config
-- doom.border_style = { "", "", "", "", "", "", "", "" }
-- doom.impatient_enabled = true
-- vim.lsp.set_log_level('trace')

vim.diagnostic.config({
  float = {
    source = "always",
  },
})

-- doom.modules.linter.settings.format_on_save = true
doom.core.reloader.settings.reload_on_save = true

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

-- Colourscheme
doom.use_package("sainnhe/sonokai", "EdenEast/nightfox.nvim")

local options = {
  dim_inactive = true,
}
local palettes = {
  dawnfox = {
    bg2 = "#F9EFEC",
    bg3 = "#ECE3DE",
    sel1 = "#EEF1F1",
    sel2 = "#D8DDDD",
  },
}
local specs = {}
local all = {
  TelescopeNormal = { fg = "fg0", bg = "bg0" },
  TelescopePromptTitle = { fg = "pallet.green", bg = "bg1" },
  TelescopePromptBorder = { fg = "bg1", bg = "bg1" },
  TelescopePromptNormal = { fg = "fg1", bg = "bg1" },
  TelescopePromptPrefix = { fg = "fg1", bg = "bg1" },

  TelescopeResultsTitle = { fg = "pallet.green", bg = "bg2" },
  TelescopeResultsBorder = { fg = "bg2", bg = "bg2" },
  TelescopeResultsNormal = { fg = "fg1", bg = "bg2" },

  TelescopePreviewTitle = { fg = "pallet.green", bg = "bg1" },
  TelescopePreviewNormal = { bg = "bg1" },
  TelescopePreviewBorder = { fg = "bg1", bg = "bg1" },
  TelescopeMatching = { fg = "error" },
  CursorLine = { bg = "sel1", link = "" },
}

require("nightfox").setup({
  options = options,
  palettes = palettes,
  specs = specs,
  all = all,
})

-- doom.colorscheme = "dawnfox"

-- Extra packages
doom.use_package(
  "rafcamlet/nvim-luapad",
  "nvim-treesitter/playground",
  -- "tpope/vim-surround",
  "dstein64/vim-startuptime"
)

-- doom.langs.lua.packages["lua-dev.nvim"] = { "max397574/lua-dev.nvim", ft = "lua" }

vim.opt.guifont = { "Hack Nerd Font", "h12" }

vim.cmd("let g:neovide_refresh_rate=60")
vim.cmd("let g:neovide_cursor_animation_length=0.03")
vim.cmd("set laststatus=3")

--
-- TELESCOPE OVERRIDES
--

local telescope_defaults = doom.modules.features.telescope.settings.defaults

telescope_defaults.layout_config.width = 0.95
telescope_defaults.layout_config.horizontal.mirror = true
telescope_defaults.layout_config.horizontal.preview_width = 0.45
telescope_defaults.winblend = 10

-- vim: sw=2 sts=2 ts=2 expandtab
