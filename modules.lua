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

    -- AI / LLMs
    "ai_chat_gpt",
    -- ai = {
    --   "ai_chat_gpt",
    -- },

    -- Language features
    "annotations", -- Code annotation generator
    "auto_install", -- Auto install LSP providers
    "autopairs", -- Automatically close character pairs
    "comment", -- Adds keybinds to comment in any language
    "linter", -- Linting and formatting for languages
    "lsp", -- Code completion
    "extra_snippets", -- Code snippets for all languages
    "context_in_code",
    "additional_vim_textobjects",

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
    "refactoring",
    "search_and_replace",
    "windows_focus",
    "quickfix_improvements",
    "increment_and_toggle_values",
    "project_root_and_cwd",
    "comments_block_headers",
    "marks",
    "folds",
    "help_and_doc_bindings_various", -- Support for help with binds and stuff
    "cursor",
    "formatting",

    -- CURSOR MOVEMENT
    "movement_lightspeed",

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
    "ui_make_transparent",

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
    "suda", -- Save using sudo when necessary
    "telescope", -- Fuzzy searcher to find files, grep code and more
    -- "telescope_extensions_various",
    "whichkey", -- An interactive sheet
    "zen",
    "music_and_audio_engineering",
    "figlet",
    "markup_bindings_and_tools",

    -- LIBRARIES
    -- "litee"
    -- "libmodal"

    social_media = {
      "discord",
    },

    various = {
      -- "move anything that cant be categorized into this folder",
      -- "everything else should be in a sub category direactory",
      -- "so that things are kept clean and not so fucking random you know"
    },
    documentation = {
      "various_docs",
    },
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

  -- NOTE: move all these into a module called various color schemes
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
    "reaper",
    "tamton_essentials",
    binds = {
      "binds_personal",
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
      "endwise", -- ??
      "ts_plugins", -- walk throughl
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
    filetype = {
      -- "filetype",        -- ???
    },
    editor = {
      -- "spellcheck",
      "surround", -- Surround text objects, eg. {([])}
      -- "gestures",        -- Mouse gestures
      -- "tabs",            -- ???
      "scroll",
      "registers",
      -- "yank",            -- Improved yank functionalities, experimental plugin `yanky.nvim`
      "undo",
      -- "printer",
      -- "sort",            -- extra binds that help with sorting lines/objects
      -- "logging",         -- binds n stuff
      "litee_symboltree",
      "litee_bookmarks",
      "litee_calltree",
      -- "code_outline",
      -- "readline",        -- ???
      "editing",
      "tweak",
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
      -- "rename",            -- ??
      -- "ripgrep",
    },
    misc = {
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
    langs = {
      -- "fennel",
      -- "latex",
      -- "lisp",
      -- "solidity",          -- ethereum lang
    },
  },
}

-- vim: sw=2 sts=2 ts=2 fdm=indent expandtab
