return {
  -- Use the global statusline
  -- @default = true
  global_statusline = true,

  -- Leader key for keybinds
  -- @default = ' '
  leader_key = " ",

  -- Enables impatent.nvim caching to speed up start time.
  -- Can cause more issues so disabled by default
  -- @default false
  impatient_enabled = true,

  -- Pins plugins to a commit sha to prevent breaking changes
  -- @default = true
  freeze_dependencies = true,

  -- Autosave
  -- false : Disable autosave
  -- true  : Enable autosave
  -- @default = false
  autosave = true,

  -- TODO: format on save

  -- Disable Vim macros
  -- false : Enable
  -- true  : Disable
  -- @default = false
  disable_macros = false,

  -- Disable ex mode
  -- false : Enable
  -- true  : Disable
  -- @default = false
  disable_ex = true,

  -- Disable suspension
  -- false : Enable
  -- true  : Disable
  -- @default = false
  disable_suspension = false,

  -- Set numbering
  -- false : Enable  number lines
  -- true  : Disable number lines
  -- @default = false
  disable_numbering = false,

  -- Set numbering style
  -- false : Shows absolute number lines
  -- true  : Shows relative number lines
  -- @default = true
  relative_num = true,

  -- h,l, wrap lines
  movement_wrap = true,

  -- Undo directory (set to nil to disable)
  -- @default = vim.fn.stdpath("data") .. "/undodir/"
  undo_dir = vim.fn.stdpath("data") .. "/undodir/",

  -- Set preferred border style across UI
  border_style = "single",

  -- Preserve last editing position
  -- false : Disable preservation of last editing position
  -- true  : Enable preservation of last editing position
  -- @default = false
  preserve_edit_pos = false,

  -- horizontal split on creating a new file (<Leader>fn)
  -- false : doesn't split the window when creating a new file
  -- true  : horizontal split on creating a new file
  -- @default = true
  new_file_split = "vertical",

  -- Enable auto comment (current line must be commented)
  -- false : disables auto comment
  -- true  : enables auto comment
  -- @default = false
  auto_comment = false,

  -- Enable Highlight on yank
  -- false : disables highligh on yank
  -- true  : enables highlight on yank
  -- @default = true
  highlight_yank = true,

  -- Use clipboard outside of vim
  -- false : won't use third party clipboard
  -- true  : enables third part clipboard
  -- @default = true
  clipboard = true,

  -- Enable guicolors
  -- Enables gui colors on GUI versions of Neovim
  -- @default = true
  guicolors = true,

  -- Show hidden files
  -- @default = true
  show_hidden = true,

  -- Hide files listed in .gitignore from file browsers
  -- @default = true
  hide_gitignore = true,

  -- Checkupdates on start
  -- @default = false
  check_updates = false,

  -- sequences used for escaping insert mode
  -- @default = { 'jk', 'kj' }
  escape_sequences = { "zm" },

  -- If you require a specific command to be run when initiating the terminal
  -- @default = ""
  term_exec_cmd = "zsh -il",

  -- Use floating windows for plugins manager (packer) operations
  -- @default = false
  use_floating_win_packer = false,

  -- Set max cols
  -- Defines the column to show a vertical marker
  -- Set to false to disable
  -- @default = 80
  max_columns = 80,

  -- Default indent size
  -- @default = 4
  indent = 4,

  -- Logging level
  -- Set doom.settings.logging level
  -- Available levels:
  --   · trace
  --   · debug
  --   · info
  --   · warn
  --   · error
  --   · fatal
  -- @default = 'info'
  logging = "info",

  -- Default colorscheme
  -- @default = doom-one
  colorscheme = "tokyonight",

  -- TODO: this one is used but hasn't been defined yet.
  -- complete_transparency = ??,

  -- Doom One colorscheme settings
  doom_one = {
    -- If the cursor color should be blue
    -- @default = false
    cursor_coloring = false,
    -- If TreeSitter highlighting should be enabled
    -- @default = true
    enable_treesitter = true,
    -- If the comments should be italic
    -- @default = false
    italic_comments = false,
    -- If the telescope plugin window should be colored
    -- @default = true
    telescope_highlights = true,
    -- If the built-in Neovim terminal should use the doom-one
    -- colorscheme palette
    -- @default = false
    terminal_colors = true,
    -- If the Neovim instance should be transparent
    -- @default = false
    transparent_background = false,
  },

  -- defaults to false of course..
  -- so that we can add binds tha easilly modify and refactor core
  -- with eg. Treesitter..
  core_dev_binds_enabled = false,

  -- Completion bindings
  --
  -- cmp defaults:
  --    select_prev_item  = "<C-p>",
  --    select_next_item  = "<C-n>",
  --    scroll_docs_fwd   = "<C-d>",
  --    scroll_docs_bkw   = "<C-f>",
  --    complete          = "<C-Space>",
  --    close             = "<C-e>",
  --    confirm           = "<CR>",
  --    tab               = "<Tab>",
  --    stab              = "<S-Tab>",
  --
  -- luasnip defaults:
  --    ...
  mappings = {
    cmp = {
      select_prev_item = "<C-p>",
      select_next_item = "<C-n>",
      scroll_docs_fwd = "<C-d>",
      scroll_docs_bkw = "<C-f>",
      complete = "<C-Space>",
      close = "<C-e>",
      confirm = "<CR>",
      tab = "<Tab>",
      stab = "<S-Tab>",
    },
    luasnip = {
      next_choice = "<C-k>",
      prev_choice = "<C-j>",
    },
  },

  -- Automatically reload local plugins during development
  reload_doom = true,
  reload_local_plugins = true,

  local_plugins_path = "",
  fork_package_cmd = "",

  doom_ui = {
    -- if false only moves cursor to file setting/data.
    use = "move_cursor",
    -- prefer updating text via Nui popups rather than entering text in the targeted file.
    prefer_nui = false,
  },
}
