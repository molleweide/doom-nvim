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

------------------------
---       TODO       ---
------------------------

-- what is a fun async command that I could create / use?
--
--
-- 1. create some kind of intervall timer thing.
-- 2. assign this to the doom user.async["job_name"] = async:new({my_job_opts})
-- 3. call my async process from the commandline and end it / modify it.
--
-- flash color every x seconds.
-- async["my_flasher"]
-- async["my_flasher].set_color = "ABC or toggle color theme.

-- use telescope packe to navigate used plugin dirs
-- create vim command that allows me to select a plugin that I want to fork if it is
-- not already forked etc.
--
-- it would be nice if I could call my `ghm` command from inside of nvim so that
-- I can run this from within nvim with a simple command.
-- canForkCurrentRepo() -> call my function, setup fork, reload vim.

-- when setting up luasnip-snippets > pass the users local snippets dir. so that
-- there is no problem with this.

-- TODO: core module
-- add binds to core that allow you to do very quick and easy inspection
-- of objects.

-- peek 5 > only log 5 first keys of a table to see what kind of pattern it is...

-- would it be possible to do something similar for neovim https://github.com/rhysd/vim.wasm

--telescope-repo > ctrl-w -> create new file and allow edit name > enter  open file

-- debug command!!! > copy visula sel lines and run do file with an appended print(vim.inspect)
-- statement so that anything that one is swiping over can be logged in a super simple  manner.

--get visual selection > use lsp to parse and see what kind of contents is in the selection.
-- then reuse this function in bindings to create snippets / binds.
--
-- OR find require statements on top and  pull them into the command and then do a log
-- so that you can log anything in the visual selection. without anyproblem?

-- lsp refactor / move chunk to new file popup inpet/select new path.

-- use docker to setup dev environments for myself.

-- command > open ranger with a specified path, eg. std('data/config/etc..')

-- prevent LOVE lua sumneko

-- create some more snippet headers level 1, 2, 3, 4, 5, 6

-- need to make macros repeatable.
--

-- i need to add connors nest fork, and look at how it would fit with my new idea of supertight syntax.
--
-- capture.nvim > nest/luasnip

-- i need to override completion commands so that it becomes much easier to navigate through
-- text fast without ever accidentally triggering a snippet or some other shit, because this
-- is very important that this flow is not interrupted.

-- command > input: filetype > enter luasnip correct file type insert after last snippet.

-- open the master binds file > find correct position how? regex? for new position, non leader bind,
-- enter bind to new index, and then write the tree back to the master file. then based on regex,
-- look at each line, and enter the position of the bind if given via input or enter last position before
-- leader.
-- if empty tree then enter tree empty.
--
-- use smart regexes to find positions even if it is in a module file.
--
-- 1. find tree start
-- 2. parse tree / or dofile into environment
-- 3.

-- contact David engelb > whenever I feel ready get in touch with him about 3d modelling.
--

-- ask pwntester how I find some of the correct graphql commands.
-- last time i noticed that I couldn't find all of the commands easilly that he is
-- using, especially the ones pertaining to discussions.
--
-- 1. look at octo and see what search terms and then go to graphql api
-- 2. what was it that I needed to find?
-- 3. ask @pwntester

-- CHECKOUT: tj devries snippets:
--  -> https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/snips/ft/go.lua

-- create a UI framework for neovim that allows you to easilly hook plugins?

-- dorothy bash formatting -> https://duckduckgo.com/?q=vim+bash+specify+formatting+indentation+project&ia=web

-- nui > neogit > use popup for ssh password

---------------------------
---       TESTING       ---
---------------------------

-- https://www.youtube.com/results?search_query=tdd
-- testing w/ plenary thread -> https://www.reddit.com/r/neovim/comments/ms05eq/testing_with_plenary_command_fails/
--
-- neogit is using plenary to write tests. i should study the tests in neogit and
-- learn how to do this type of stuff myself. and then later maybe I can
--
-- this would mean that I should add a makefile to the doom project so that one can run tests on it
-- so I could copy this from neogit and see if I can apply some tests to doom.
-- i dunno how easy this would be
--
--
-- I should apply tdd patterns from plenary and build good tests for doom?
-- do it for the sake of it so that I learn how to to tdd which is good.
--

-- https://github.com/ThePrimeagen/refactoring.nvim/blob/master/lua/refactoring/dev.lua
-- look at this dev lib. should I create something similar for doom? and name the module `dev`
-- i have to learn how lua dev works so that I can leverage those features.

-----------------------------
---       JIBBERISH       ---
-----------------------------

-- the goal was 215 by november, that is at least what I am going to get to but
-- it is so much fun. oh fuck I am moving weight dude. let's do a shot dude.
--
-- i have to look into the refactor project and see how it is done.
-- and so how to get c errors in quickfix list.
--
-- rust/go compiler errors into quickfix. learn how to do this. and get to know
-- quickfix list more in general so that I can get nice automated ways of managing
-- errors and warnings, and I have to see how to qf list works with lsp servers as
-- well and see if I can get an as fast way of getting to errors as possible.
--
-- we don't have anything to hide so that is the reason why they did that probably and so that is something that you might want toggle
-- anders knape. the leader of swedish communes.
--
-- it seems that I should be able to use the treesitter lib and use it since it has a lot of nice helper functions that allow you
-- to do the things that I need. and so that is something that should maybe go into treesitter.
--
-- so how does it feel now to do this
--
-- jibbersish dude
--
--
--
-- !!!! !!

-----------------------------
---       RESOURCES       ---
-----------------------------

-- TEXT
--    dockerfile lab    -> https://docker.github.io/get-involved/docs/communityleaders/eventhandbooks/docker101/dockerfile/#understanding-image-layering-concept-with-dockerfile
--
--    https://www.simplilearn.com/tutorials/docker-tutorial/getting-started-with-docker?source=sl_frs_nav_playlist_video_clicked
--
--
--    dockerfile        -> https://www.simplilearn.com/tutorials/docker-tutorial/what-is-dockerfile
--    docker image      -> https://www.simplilearn.com/tutorials/docker-tutorial/docker-images
--    dockercontainer   -> https://www.simplilearn.com/tutorials/docker-tutorial/what-is-docker-container
--
--    METATABLE
--      https://www.tutorialspoint.com/lua/lua_metatables.htm
--      https://microsoft.github.io/language-server-protocol/specifications/specification-current/
--
--
--    LSP
--      https://microsoft.github.io//language-server-protocol/overviews/lsp/overview/
--
-- VIDEOS
--    nvim from scratch playlist -> https://www.youtube.com/playlist?list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ
--    lsp config cont@4.30 -> https://www.youtube.com/watch?v=6F3ONwrCxMg&list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ&index=8
--
--    docker 3h tutorial -> https://www.youtube.com/watch?v=3c-iBn73dDE

-------------------------
---       DEBUG       ---
-------------------------

-- local config = vim.tbl_deep_extend("force", {
--   capabilities = utils.get_capabilities(),
--   on_attach = function(client)
--     if not is_plugin_disabled("illuminate") then
--       utils.illuminate_attach(client)
--     end
--     if type(doom.lua.on_attach) == "function" then
--       doom.lua.on_attach(client)
--     end
--   end,
-- })

-- print(vim.inspect(utils.get_capabilities()))
-- print(vim.inspect(utils.illuminate_attach()))
-- print(vim.inspect(doom.lua.on_attach()))

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
doom.settings.autosave = false
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

-- TODO: MOVE INTO UTIL
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

-- local use = doom.use_package
-- local m = doom.modules

-- m.neogit.packages["neogit"][1] = gh .. "TimUntersberger/neogit"

-- --- test generate annotation with neogen
-- local snippets = doom.modules.snippets
--
-- --- another neogen commment
-- snippets.packages["LuaSnip"][1] = gh .. "L3MON4D3/LuaSnip"
--
-- table.insert(snippets.packages["LuaSnip"].requires, {
--   "molleweide/LuaSnip-snippets.nvim", -- opt = true,
-- })
--
-- --- here neogen works but not for the table insert above
-- snippets.configs["LuaSnip"] = function()
--   local ls = require("luasnip")
--   ls.config.set_config(snippets.settings)
--   ls.snippets = require("luasnip_snippets").load_snippets()
--   require("luasnip.loaders.from_vscode").load()
-- end

-- use({ gh .. "cljoly/telescope-repo.nvim" })
-- use({ gh .. "nvim-telescope/telescope-packer.nvim" })
--
-- -- -- -- add ext to tele config
-- table.insert(doom.modules.telescope.settings.extensions, "repo")
-- table.insert(doom.modules.telescope.settings.extensions, "packer")
--

doom.settings.colorscheme = "tokyonight"

doom.use_cmd({
  "Test",
  function(opts)
    print("test", opts.args)
  end,
  -- { nargs = 1 },
})

-- doom.use_autocmd({
--   {
--     "FileType",
--     "lua",
--     function()
--       print("lua")
--     end,
--   },
-- })

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
doom.core.reloader.settings.reload_on_save = false

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
doom.colorscheme = "dawnfox"

-- Extra packages
doom.use_package(
  "rafcamlet/nvim-luapad",
  "nvim-treesitter/playground",
  "tpope/vim-surround",
  "dstein64/vim-startuptime"
)

doom.langs.lua.packages["lua-dev.nvim"] = { "max397574/lua-dev.nvim", ft = "lua" }

vim.opt.guifont = { "Hack Nerd Font", "h12" }

vim.cmd("let g:neovide_refresh_rate=60")
vim.cmd("let g:neovide_cursor_animation_length=0.03")
vim.cmd("set laststatus=3")

-- vim: sw=2 sts=2 ts=2 expandtab
