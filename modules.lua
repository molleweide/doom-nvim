-- modules.lua - Doom nvim module selection
--
-- modules.lua controls what Doom nvim plugins modules are enabled and
-- what features are being used.
--
-- Uncomment a plugin to enable it and comment out to disable and uninstall it.
-- Once done, restart doom-nvim and run `:PackerInstall`.

-- TODO: add custom colors for subtable strings so that it is easier to
-- read see which are the modules parent dirs?
--    or maybe this is just fixed with the ts-context plugin maybe?

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
    "context_in_code",

    -- Editor
    "auto_session", -- Remember sessions between loads
    "colorizer", -- Show colors in neovim
    "editorconfig", -- Support editorconfig files
    -- "gitsigns", -- Show git changes in sidebar
    "illuminate", -- Highlight other copies of the word you're hovering on
    "indentlines", -- Show indent lines with special characters
    "range_highlight", -- Highlight selected range from commands
    "todo_comments", -- Highlight TODO: comments
    "doom_themes", -- Extra themes for doom
    "colors_multiple_plugins",
    "clipboard_neoclip",
    "clipboard_images",

    -- MOTION

    -- UI COMPONENTS
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
    -- "dui", -- [WIP] Managen your doom config with Telescope.

    -- TOOLS
    "dap", -- Debug code through neovim
    "repl",
    "email_himalaya",
    "explorer", -- An enhanced filetree explorer
    "firenvim", -- Embed neovim in your browser
    "lazygit", -- Lazy git integration
    "neogit", -- A git client for neovim
    -- "netrw",
    "neorg", -- Organise your life
    "projects", -- Quickly switch between projects
    "superman", -- Read unix man pages in neovim
    "suda",            -- Save using sudo when necessary
    "telescope", -- Fuzzy searcher to find files, grep code and more
    "whichkey", -- An interactive sheet
    "zen",

    -- LIBRARIES
    -- "litee"
    -- "libmodal"
  },
  -- ui = {
  --   heirline,
  --   fidget,
  --   ...
  -- },
  -- version_control = {
  --   git = {},
  --   github = {},
  -- },
  langs = {
    "lua",
    "python",
    "bash",
    -- "fish",
    -- "gdscript",
    -- "gdscript",
    -- "php",
    -- "ruby",

    -- Web
    "javascript",
    "typescript",
    "css",
    "vue",
    -- "tailwindcss",
    -- "svelte",

    -- Compiled
    "rust",
    "cc",
    -- "ocaml",
    -- "haskell",

    -- JIT
    -- "c_sharp",
    -- "kotlin",
    -- "java",

    -- "json",
    -- "yaml",
    -- "toml",
    "markdown",
    -- "terraform",       -- Terraform / hcl files support
    "dockerfile",
    -- "nix",             -- Nix declarations
  },
  themes = {
    -- Themes designed for neovim
    nvim = {
      "apprentice",
      "aurora",
      "cassiopeia",
      "catppuccin",
      "github",
      "gruvbox",
      "gruvbuddy",
      "material",
      "monochrome",
      "monokai",
      "moonlight",
      "neon",
      "nightfox",
      "nord",
      "nvcode",
      "nvim_deus",
      "oak",
      "oceanic_next",
      "one",
      "onedark",
      "onenord",
      "roshivim",
      "solarized",
      "sonokai",
      "spaceduck",
      "starry",
      "sunflower",
      "tokyonight",
      "vscode",
      -- "base16",
      -- "blue_moon",
      -- "boo",
      -- "calvera",
      -- "catpuccino",
      -- "cobalt",
      -- "codeschool",
      -- "dracula",
      -- "edge",
      -- "everforest",
      -- "falcon",
      -- "gloombuddy",
      -- "gruvbox-baby",
      -- "gruvbox-material",
      -- "hybrid",
      -- "jellybeans",
      -- "kanagawa",
      -- "kosmikoa",
      -- "kyoto",
      -- "modus",
      -- "nordic",
      -- "one_monokai",
      -- "onebuddy",
      -- "onedarkpro",
      -- "papadark",
      -- "rasmus",
      -- "rdark",
      -- "space",
      -- "substrata",
      -- "tokyodark",
      -- "uwu",
      -- "vim_code_dark",
      -- "vimdark",
      -- "vn_night",
      -- "xresources",
      -- "zenbones",
      -- "zephyr",
      -- "zephyrium",
    },
    -- Themes designed for original Vim
    vim = {
      "ariake",
      "iceberg",
      "tender",
      "fly",
      "aquarium",
      "omni",
    },
  },
  move_to_core = {
    "execute_anything_tj_style",
  },
  molleweide = {
    ai = {
      "chat_gpt",
      -- "copilot",
      -- "magic",
    },
    binds = {
      "binds_personal",
      -- "binds_debug",
      -- "binds_make_fn_under_cursor_into_bind",
      -- "binds_mini_syntax",
      -- "make_inclusive",  -- Make various binds/plugins inclusive, ie. include cursor position in eg `f/F`
      -- "mappings",
      -- "legend",        -- ???
    },
    context = {
      -- "winbar_statusline_context",
    },
    dorothy = {
      "dorothy",
    },
    finance = {
      -- "crypto_prices",
    },
    language_features = {
      -- "virtual_types", -- ???
      "args", -- Provides highlighting and tools for managing function args
      "textobjects",
      "endwise", -- ??
      "ts_plugins", -- walk through
    },
    lang_binds = {
      -- "rust_binds",
    },

    lib = {
      "litee", -- Litee IDE suite
      -- "libmodal",          -- Tool for creating custom modes
    },
    buffers = {
      -- "buffers",
    },
    cmdline = {
      -- "floating_cmdline", -- Floating cmdline at cursor
      -- "floating_search", -- Floating cmdline at cursor
      -- "wildmenu",
    },
    competitive = {
      -- "competitive",
    },
    documentation = {
      "docs",
      "figlet",
      "comments_frame",
    },
    filetype = {
      -- "filetype",        -- ???
    },
    editor = {
      -- "spellcheck",
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
      "help", -- Support for help with binds and stuff
      -- "printer",
      -- "sort",            -- extra binds that help with sorting lines/objects
      -- "logging",         -- binds n stuff
      "litee_symboltree",
      "litee_bookmarks",
      "litee_calltree",
      -- "code_outline",
      "root", -- Auto switch root on-enter new git repo + useful commands
      -- "readline",        -- ???
      "editing",
      "formatting",
      "tweak",
      "xml",
    },
    games = {},
    icons = {
      -- "icons",             -- Extended various icons support
    },
    images = {
      -- "images",        -- Image support
    },
    jobs = {},
    data_science = {
      -- "data_science",
    },
    nvim_dev = {
      "plugins_reloader", -- Watch local packages for changes during development
      "nvim_dev_binds",
    },
    tabs = {},
    windows = {
      "focus",
      -- "window_binds",
      "wm",
    },
    motion = {
      "lightspeed", -- Replace `s` with advanced leap.nvim motion plugin.
      -- "leap",
      -- "sneak",
      -- "tree_hopper",
    },
    git = {
      "git", -- git basic support
      -- "gitsigns",
      -- "vgit",
      "diffview", -- git diffview integration
      -- "repo_search",
      "github_octo",
      "github_litee",
      "ghq",
    },
    transform = {
      -- "regex",           -- Regex tools
      -- "architext",
      "refactor",
      -- "rename",            -- ??
      -- "ripgrep",
      "search_and_replace",
    },
    misc = {
      "telescope_extensions", -- move into categories
      -- "kmonad",            -- Support for kmonad keyboard remapper
      -- "navigator",         -- ???
      -- "statusline_misc",
      -- "markdown_tools",  -- ??
      -- "figlet",            -- figlet fonts editor
      -- "websearch",
      -- "stenography",
      -- "utilities",         -- ??
      -- "math_calculator",
      -- "games",
    },
    music = {
      -- "audio",
      "reaper",
    },
    tabular = {
      -- "scim",              -- Spreadsheets
      -- "tabular",           -- Extended support for managing tabular data
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
    tools = {
      -- "flutter",
      -- "google_docs",
      -- "ssh",
      -- "open_scad",
      -- "docker",          -- Docker tools
      -- "pandoc",
      -- "remote_dev",      -- ???
      "gpg",
      "collaborate", -- Google docs collaborative editing.
    },
    tmux = {
      -- "tmux",               -- ???
    },
    quickfix = {
      "quickfix", -- Extra quickfix capabilitieS
    },
    ui = {
      -- "crypto",            -- Crypto currency stuff
      -- "diagrams",
      -- "vim_ui",            -- improved `vim.ui`
      "transparent",
      -- "noice"
    },
    langs = {
      -- "fennel",
      -- "latex",
      -- "lisp",
      -- "solidity",          -- ethereum lang
    },
  },
}

-- vim: sw=2 sts=2 ts=2 fdm=indent expandtab
