-- modules.lua - Doom nvim module selection
--
-- modules.lua controls what Doom nvim plugins modules are enabled and
-- what features are being used.
--
-- Uncomment a plugin to enable it and comment out to disable and uninstall it.
-- Once done, restart doom-nvim and run `:PackerInstall`.

-- TODO: REDO COMMENT HEADERS WITH FIGLET

-- TODO: AUTOMATICALLY SYNC THIS FILE WITH THE MODULES DIR.
--
-- requires
--  - recurse modules dir
--  - rewrite this file with an additional `category` dir that gives
--      you higher clarity
--  - maintain `enabled` states, ie. check if TSComment contains `module name` pattern.

-- TODO: collect sections programmatically instead of using
--      create sync command that syncs new modules to here.

return {
  features = {
    -- Language features
    "annotations", -- Code annotation generator
    "auto_install", -- Auto install LSP providers
    "autopairs", -- Automatically close character pairs
    "comment", -- Adds keybinds to comment in any language
    "linter", -- Linting and formatting for languages
    "lsp", -- Code completion
    "extra_snippets", -- Code snippets for all languages

    -- Editor
    "auto_session", -- Remember sessions between loads
    "colorizer", -- Show colors in neovim
    "editorconfig", -- Support editorconfig files
    -- "gitsigns", Show git changes in sidebar
    "illuminate", -- Highlight other copies of the word you're hovering on
    "indentlines", -- Show indent lines with special characters
    "range_highlight", -- Highlight selected range from commands
    "todo_comments", -- Highlight TODO: comments
    "doom_themes", -- Extra themes for doom

    -- UI Components
    "lsp_progress", -- Check status of LSP loading
    "tabline", -- Tab bar buffer switcher
    "dashboard", -- A pretty dashboard upon opening
    "trouble", -- A pretty diagnostic viewer
    "statusline", -- A pretty status line at the bottom of the buffer
    -- "minimap",         -- Shows current position in document
    "terminal", -- Integrated terminal in neovim
    "symbols", -- Navigate between code symbols using telescope
    "ranger", -- File explorer in neovim (TODO: Test)
    "restclient", -- Test HTTP requests from neovim (TODO: Test)
    "show_registers", -- Show and navigate between registers
    "dui", -- [WIP] Managen your doom config with Telescope.

    -- Tools
    -- "dap",             -- Debug code through neovim
    "repl",
    "explorer", -- An enhanced filetree explorer
    "firenvim", -- Embed neovim in your browser
    "lazygit", -- Lazy git integration
    "neogit", -- A git client for neovim
    -- "netrw",
    "neorg", -- Organise your life
    "projects", -- Quickly switch between projects
    "superman", -- Read unix man pages in neovim
    -- "suda",            -- Save using sudo when necessary
    "telescope", -- Fuzzy searcher to find files, grep code and more
    "whichkey", -- An interactive sheet
    "zen",
  },
  langs = {
    "lua",
    "python",
    "bash",
    -- "fish",

    -- Web
    "javascript",
    "typescript",
    "css",
    "vue",
    -- "tailwindcss",
    "glsl",

    -- Compiled
    "rust",
    "cc",
    -- "ocaml",

    -- JIT
    -- "c_sharp",
    -- "kotlin",
    -- "java",

    "config", -- JSON, YAML, TOML
    "markdown",
    -- "terraform",       -- Terraform / hcl files support
    "dockerfile",
  },
  themes = {
    -- "apprentice",
    -- "aquarium",
    -- "ariake",
    "aurora",
    -- "base16",
    -- "blue_moon",
    -- "boo",
    -- "calvera",
    "cassiopeia",
    -- "catpuccino",
    -- "cobalt",
    -- "codeschool",
    -- "dracula",
    -- "edge",
    -- "everforest",
    -- "falcon",
    "fly",
    "github",
    -- "gloombuddy",
    "gruvbox",
    -- "gruvbox-baby",
    -- "gruvbox-material",
    "gruvbuddy",
    -- "gruvy",
    -- "hybrid",
    -- "jellybeans",
    -- "kanagawa",
    -- "kosmikoa",
    -- "kyoto",
    "material",
    -- "modus",
    -- "monochrome",
    "monokai",
    -- "moonlight",
    -- "neon",
    "nightfox",
    "nord",
    -- "nordic",
    -- "nvcode",
    -- "nvim_deus",
    -- "oak",
    "oceanic_next",
    -- "omni",
    -- "one",
    -- "one_monokai",
    -- "onebuddy",
    -- "onedark",
    -- "onedarkpro",
    -- "onenord",
    -- "papadark",
    -- "rasmus",
    -- "rdark",
    -- "roshivim",
    -- "starry",
    "solarized",
    "sonokai",
    -- "space",
    -- "substrata",
    -- "sunflower",
    -- "tokyodark",
    "tokyonight",
    -- "uwu",
    -- "vim_code_dark",
    -- "vimdark",
    -- "vn_night",
    -- "vscode",
    -- "xresources",
    -- "zenbones",
    -- "zephyr",
    -- "zephyrium",
  },
  move_to_core = {
    -- "gitsigns",           -- Show git changes in sidebar
    "git", -- git basic support
    "diffview", -- git diffview integration

    -- "cmdline", -- Floating cmdline at cursor
    -- "wildmenu",
    "quickfix", -- Extra quickfix capabilitieS
    -- "images",        -- Image support
    -- "legend",        -- ???
    -- "vim_ui",            -- improved `vim.ui`
    -- "virtual_types", -- ???
    -- "code_outline",
    -- "transparent",

    "colors",
    "search_and_replace", -- Binds for search and replace
    -- "architext",
    -- "context", -- Provides visual context via Treesitter
    "args", -- Provides highlighting and tools for managing function args
    "textobjects",
    "comments_frame", -- Create big comments with a nice frame
    "endwise", -- ??
    "ts_plugins", -- walk through
    "root", -- Auto switch root on-enter new git repo + useful commands
    -- "buffers",
    -- "readline",        -- ???
    -- "filetype",        -- ???
    -- "make_inclusive",  -- Make various binds/plugins inclusive, ie. include cursor position in eg `f/F`

    -- "ghq", -- Support for `qhq` repo manager

    -- "ai",
    "gpg",
    "collaborate", -- Google docs collaborative editing.
    "plugins_reloader", -- Watch local packages for changes during development
    "refactor", -- Code refactoring
    -- "ripgrep",
    -- "flutter",
    -- "markdown_tools",  -- ??
    -- "google_docs",
    -- "ssh",
    -- "docker",          -- Docker tools
    -- "pandoc",
    -- "remote_dev",      -- ???
    -- "tmux",               -- ???
  },
  personal = {
    "docs",
    "editing",
    "formatting",
    "tweak",
    "windows",
    "wm",
    -- "tmux",

    "telescope_extensions", -- move into categories
    -- "crypto",            -- Crypto currency stuff
    -- "rename",            -- ??
    -- "spellcheck",
    -- "diagrams",
    -- "competitive",
    -- "libmodal",          -- Tool for creating custom modes
    -- "icons",             -- Extended various icons support
    -- "figlet",            -- figlet fonts editor
    -- "kmonad",            -- Support for kmonad keyboard remapper
    -- "navigator",         -- ???
    -- "games",
    -- "websearch",
    -- "data_science",
    -- "stenography",
    -- "statusline_misc",
    -- "utilities",         -- ??
    -- "math_calculator",
  },
  -- tabular = {
  --   -- "scim",              -- Spreadsheets
  --   -- "tabular",           -- Extended support for managing tabular data
  -- },
  molleweide = {
    binds = {
      "binds_personal",
      -- "binds_debug",
      -- "binds_make_fn_under_cursor_into_bind",
      -- "binds_mini_syntax",
      -- "mappings",
    },
    lib = {
      "litee", -- Litee IDE suite
    },
    editor = {
      "surround", -- Surround text objects, eg. {([])}
      "cursor",
      -- "gestures",        -- Mouse gestures
      -- "tabs",            -- ???
      "scroll",
      "registers",
      -- "yank",            -- Improved yank functionalities, experimental plugin `yanky.nvim`
      "marks",
      "undo",
      "folds",
      "increment", --  tools for incrementing stuff
      "clipboard",
      -- "regex",           -- Regex tools
      -- "help",            -- Support for help with binds and stuff
      -- "printer",
      -- "sort",            -- extra binds that help with sorting lines/objects
      -- "logging",         -- binds n stuff
      "litee_symboltree",
      "litee_bookmarks",
      "litee_calltree",
    },
    tabs = {},
    windows = {},
    motion = {
      "lightspeed", -- Replace `s` with advanced leap.nvim motion plugin.
      -- "leap",
      -- "sneak",
    },
    git = {
      -- "repo_search",     -- Browse repos in Telescope.
      "github_octo",
      "github_litee", -- Litee IDE suite
    },
    transform = {},
    music = {
      -- "audio",
      -- "reaper_keys",
    },
    ts = {
      -- "ts_jump_2_func",
      -- "ts_jump_to_module_part",
      -- "ts_mirror_doom_globals",
      -- "ts_navigation",
      -- "ts_query_monitor",
      -- "ts_testing",
      -- "ts_testing_locals",
      -- "ts_treehopper",
    },
    tools = {},
    langs = {

      -- "fennel",
      -- "latex",
      -- "lisp",
      -- "solidity",          -- ethereum lang
    },
  },
}

-- vim: sw=2 sts=2 ts=2 fdm=indent expandtab
