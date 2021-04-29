"================================================
" doom.vim - Init and core config of Doom Nvim
" Author: NTBBloodbath
" License: MIT
"================================================

" Doom Nvim version
let g:doom_version = '2.0.0'
lockvar g:doom_version

" Force UTF-8 encoding
scriptencoding utf-8

" Enable autosave
" @default = 0
let g:doom_autosave = 0

" Enable format on save
" @default = 0
let g:doom_fmt_on_save = 0

" Autosave sessions
" @default = 0
let g:doom_autosave_sessions = 0

" Preserve last editing position
" @default = 0
let g:doom_preserve_edit_pos = 1

" Default indent size
" @default = 4
let g:doom_indent = 4

" Show indent lines
" @default = 1
let g:doom_show_indent = 1

" Expand tabs
" @default = 1
let g:doom_expand_tabs = 1

" Set numbering
" @default = 1
let g:doom_relative_num = 1

" Set max cols
" @default = 80
let g:doom_max_columns = 80

" Enable guicolors
" @default = 1
let g:doom_enable_guicolors = 1

" Sidebar sizing
" @default = 25
let g:doom_sidebar_width = 25

" Tagbar left
" @default = 1
let g:doom_tagbar_left = 1

" Show hidden files
" @default = 1
let g:doom_show_hidden = 1

" Default colorscheme
" @default = doom-one
let g:doom_colorscheme = 'doom-one'

" Background color
" @default = dark
let g:doom_colorscheme_bg = 'dark'

" Check updates of plugins on start
" @default = 0
let g:doom_check_updates = 0

" Disabled plugins
" @default = ['lazygit', 'minimap', 'restclient']
" example:
"   let g:doom_disabled_plugins = ['emmet-vim']
let g:doom_disabled_plugins = ['lazygit', 'minimap', 'restclient']

" Disabled plugins modules
" @default = ['git', 'lsp', 'web']
" example:
"   let g:doom_disabled_modules = ['web']
let g:doom_disabled_modules = ['git', 'lsp', 'web']

" Install custom plugins
" @default = []
" examples:
"   plugins without options:
"       let g:doom_custom_plugins = ['andweeb/presence.nvim']
"   plugins with options:
"       let g:doom_custom_plugins = [
"           \ {
"           \     'repo': 'andweeb/presence.nvim',
"           \     'enabled': 1,
"           \ }
"           \ ]
let g:doom_custom_plugins = []

" Set the parsers for TreeSitter
" @default = []
" example:
"   let g:doom_ts_parsers = ['python', 'javascript']
let g:doom_ts_parsers = []

" Conceal level
" Set Neovim conceal level
" 0 : Disable indentline and show all
" 1 : Conceal some functions and show indentlines
" 2 : Concealed text is completely hidden unless it has a custom replacement
"     character defined
" 3 : Concealed text is completely hidden
let g:doom_conceallevel = 0

" Logging level
" 0 : No logging
" 1 : All errors, no echo (default)
" 2 : All errors and messages, no echo
" 3 : All errors and messages, echo
" @default = 1
let g:doom_logging = 1


" Check if running Neovim or Vim and fails if
" 1. Running Vim instead of Neovim
" 2. Running Neovim 0.4 or below
if has('nvim')
    if has('nvim-0.5')
        let g:doom_neovim = 1
    else
        call doom#logging#message('!!!', 'Doom Nvim requires Neovim 0.5.0', 2)
    endif
else
    call doom#logging#message('!!!', 'Doom Nvim does not have support for Vim, please use it with Neovim instead!', 2)
endif
lockvar g:doom_neovim

function! doom#loadConfig(file) abort
    if filereadable(g:doom_root . 'config/' . a:file)
        execute 'source ' . g:doom_root . 'config/' . a:file
        call doom#logging#message('+', 'Sourced file '.a:file, 2)
    endif
endfunction

" Doom Nvim path
" @default = /home/user/.config/doom-nvim/
let g:doom_root = expand('$HOME/.config/doom-nvim')
lockvar g:doom_root

" Call Functions
function! doom#begin() abort
    " Check for a doomrc
    call doom#config#checkBFC()
    if g:doom_bfc ==# 1
        call doom#config#loadBFC()
    endif

    call doom#autocmds#init()
    call doom#system#whichos()
    call doom#default#options()
endfunction

function! doom#end() abort
    call doom#default#loadGlob()
    " Test source system-based
    call doom#system#grepconfig('config', 'keybindings.vim', 1)

    " Plugins, configs are loaded only if the plugin is enabled.
    if index(g:doom_disabled_plugins, 'vista') == -1
        call doom#system#grepconfig('config/plugins', 'vista.vim', 1)
    endif
    if index(g:doom_disabled_plugins, 'neoformat') == -1
        call doom#system#grepconfig('config/plugins', 'neoformat.vim', 1)
    endif
    call doom#system#grepconfig('config/plugins', 'leader-mapper.vim', 1)

    " Check updates
    call doom#logging#init()
    if g:doom_check_updates ==# 1
        call doom#system#checkupdates()
    endif
endfunction

" vim: cc=80:
