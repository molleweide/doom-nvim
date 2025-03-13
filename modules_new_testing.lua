-- modules.lua - Doom nvim module selection
-- modules.lua controls what Doom nvim plugins modules are enabled and
-- what features are being used.
--
-- Uncomment a plugin to enable it and comment out to disable and uninstall it.
--
-- TODO: Use https://github.com/mtrajano/tssorter.nvim to sort this table
-- automatically.
--
-- TODO: Make every single module as a boolean here below, that would make it
-- possible to do `module = <boolean>` and that would only require loading this
-- table in order to get the info quickly on every single module.
-- This would allow for easilly loading and unloading modules without having to
-- write to this file.

-- TEST: new modules pattern
-- 1. use uppercase for category keys.
-- 2. use tables for each module

return {
  AI = {
    { "ai_chat_gpt", enabled = true },
  },
  LIB = {
    { "nio", enabled = true },     -- asynch IO
  },
  FEATURES = {
    { "architext",         enabled = true },
    { "monitoring",        enabled = true },

    { "lsp_progress",      enabled = true },

    { "file_explorer_oil", enabled = true },

    BUFFERS = {
      { "buffer_management", enabled = true },
      { "temporary_buffers", enabled = true },
      { "cleanup_unused",    enabled = true },
    },
    -- {"testmodule", enabled = true},
    { "task_and_job_manager",       enabled = true },
    LIB = {
      { "litee",   enabled = true },
      { "pathlib", enabled = true },
    },

    COMPLETIONS = {
      -- {"cmp_nvim", enabled = true},
      -- "coc"
    },

    SNIPPETS = {
      { "extra_snippets",               enabled = true }, -- Code snippets for all languages
      { "luasnip_engine",               enabled = true, tags = { "reduced", "firenvim" } },
      { "additional_friendly_snippets", enabled = true, tags = { "reduced", "firenvim" } },
      { "luasnip_telescope",            enabled = true },
    },

    -- Language features
    { "annotations",                enabled = true }, -- Code annotation generator
    { "auto_install",               enabled = true }, -- Auto install LSP providers
    { "autopairs",                  enabled = true }, -- Automatically close character pairs
    { "comment",                    enabled = true }, -- Adds keybinds to comment in any language
    { "linter",                     enabled = true }, -- Linting and formatting for languages
    { "lsp",                        enabled = true }, -- Code completion
    { "lsp_cmp",                    enabled = true },
    { "lsp_signature_hints",        enabled = true },
    { "context_in_code",            enabled = true },
    { "additional_vim_textobjects", enabled = true },
    LANGUAGE_FEATURES = {
      -- {"virtual_types", enabled = true}, -- ???
      { "auto_add_end_keyword",      enabled = true },
      { "highlight_args_and_params", enabled = true },
      -- {"preview_edit_and_navigate_lsp_locations", enabled = true},
      { "swap_args_and_elems",       enabled = true },
      { "ts_plugins",                enabled = true },
    },

    -- TODO: Move all lsp stuff into this directory...
    LSP = {
      -- {"lspconfig", enabled = true},
    },

    -- Editor
    { "auto_session",      enabled = true },   -- Remember sessions between loads
    { "colorizer",         enabled = true },   -- Show colors in neovim
    { "editorconfig",      enabled = true },   -- Support editorconfig files
    -- {"gitsigns", enabled = true}, -- Show git changes in sidebar
    { "illuminate",        enabled = true },   -- Highlight other copies of the word you're hovering on
    { "indentlines",       enabled = true },   -- Show indent lines with special characters
    { "range_highlight",   enabled = true },   -- Highlight selected range from commands
    { "todo_comments",     enabled = true },   -- Highlight TODO: comments
    { "doom_themes",       enabled = true },   -- Extra themes for doom
    { "color_pickers",     enabled = true },
    { "clipboard_neoclip", enabled = true },
    { "clipboard_images",  enabled = true },
    REFACTOR = { { "refactoring", enabled = true }, "exemplum" },
    { "search_and_replace",            enabled = true },
    { "quickfix_improvements",         enabled = true },
    { "increment_and_toggle_values",   enabled = true },
    { "project_root_and_cwd",          enabled = true },
    { "comments_block_headers",        enabled = true },
    { "marks",                         enabled = true },
    { "folds",                         enabled = true },
    { "help_and_doc_bindings_various", enabled = true },     -- Support for help with binds and stuff
    { "cursor",                        enabled = true },
    { "formatting",                    enabled = true },
    EDITOR = {
      -- {"spellcheck", enabled = true},
      { "surround",                enabled = true }, -- Surround text objects, eg. {([])}
      -- {"gestures", enabled = true},        -- Mouse gestures
      -- {"tabs", enabled = true},            -- ???
      { "scroll",                  enabled = true },
      { "registers",               enabled = true },
      { "undo_tree_visualization", enabled = true },
      -- {"printer", enabled = true},
      -- {"sort", enabled = true},            -- extra binds that help with sorting lines/objects
      -- {"logging", enabled = true},         -- binds n stuff
      -- {"litee_symboltree", enabled = true},
      -- {"litee_bookmarks", enabled = true},
      -- {"litee_calltree", enabled = true},
      -- {"code_outline", enabled = true},
      -- {"readline", enabled = true},        -- ???
      { "editing",                 enabled = true },
    },

    -- CURSOR MOVEMENT
    { "movement_lightspeed", enabled = true },

    -- UI COMPONENTS
    { "tabline",             enabled = true }, -- Tab bar buffer switcher
    { "dashboard",           enabled = true }, -- A pretty dashboard upon opening
    { "trouble",             enabled = true }, -- A pretty diagnostic viewer
    { "statusline",          enabled = true }, -- A pretty status line at the bottom of the buffer
    -- {"minimap", enabled = true},         -- Shows current position in document

    { "terminal",            enabled = true }, -- Integrated terminal in neovim
    TERMINAL = {
      -- TODO: Move terminal related plugins into this dir
    },

    NVIM_HELP = {
      { "vimdoc_and_help_decorations", enabled = true },
    },

    { "symbols_outline_sidebar",    enabled = true },  -- Navigate between code symbols using telescope
    { "ranger",                     enabled = true },  -- File explorer in neovim (TODO: Test)
    { "restclient",                 enabled = true },  -- Test HTTP requests from neovim (TODO: Test)
    { "show_registers",             enabled = true },  -- Show and navigate between registers
    { "dui",                        enabled = true },  -- [WIP] Managen your doom config with Telescope.
    { "ui_make_transparent",        enabled = true },
    { "ui_custom_vim_input_select", enabled = true },
    UI = {
      { "noice_ergonomic_ui", enabled = true },
    },

    -- TOOLS
    { "dap",                         enabled = true }, -- Debug code through neovim
    { "repl",                        enabled = true },
    { "email_himalaya",              enabled = true },
    { "explorer",                    enabled = true },                   -- An enhanced filetree explorer
    { "firenvim",                    enabled = true },                   -- Embed neovim in your browser
    { "lazygit",                     enabled = true },                   -- Lazy git integration
    { "neogit",                      enabled = true },                   -- A git client for neovim
    -- {"netrw", enabled = true},
    { "neorg",                       enabled = true },                   -- Organise your life
    { "superman",                    enabled = true },                   -- Read unix man pages in neovim
    { "suda",                        enabled = true },                   -- Save using sudo when necessary
    { "telescope",                   enabled = true },                   -- Fuzzy searcher to find files, grep code and more
    -- {"telescope_extensions_various", enabled = true},
    { "whichkey",                    enabled = true, tags = { "reduced", "firenvim" } }, -- An interactive sheet
    { "zen",                         enabled = true },
    { "music_and_audio_engineering", enabled = true },
    { "figlet",                      enabled = true },
    { "markup_bindings_and_tools",   enabled = true },

    TOOLS = {
      { "spreadsheets", enabled = true },
      -- {"flutter", enabled = true},
      -- {"google_docs", enabled = true},
      -- {"ssh", enabled = true},
      -- {"open_scad", enabled = true},
      -- {"docker", enabled = true},          -- Docker tools
      -- {"pandoc", enabled = true},
      -- {"remote_dev", enabled = true},      -- ???
      -- {"gpg", enabled = true},
      -- {"collaborate", enabled = true}, -- Google docs collaborative editing.
    },

    -- LIBRARIES
    -- "litee"
    -- "libmodal"

    SOCIAL_MEDIA = {
      { "discord", enabled = true },
    },

    VARIOUS = {
      -- "move anything that cant be categorized into this folder",
      -- "everything else should be in a sub category direactory",
      -- "so that things are kept clean and not so fucking random you know"
    },
    DOCUMENTATION = {
      { "various_docs", enabled = true },
    },
    WINDOWS = {
      { "auto_focus_and_auto_resize", enabled = true },
      { "center_focused_window",      enabled = true },
    },

    WORKSPACE_MANAGEMENT = {
      { "projects",         enabled = true }, -- Quickly switch between projects
      { "system_git_repos", enabled = true },
      { "ghq",              enabled = true },
    },

    -- TODO: ypc and clipboard should go under `editor`
    -- Rename to `ypc_and_clipboard`
    YANK_PUT_AND_CUT = {
      { "ypc_binds", enabled = true },
      -- {"yank_cmp_source", enabled = true},
      -- {"yank_improved", enabled = true},
      -- {"yank_smart_flow", enabled = true},
    },
  },
  UI = {
    -- {"sidebar_generic_modular", enabled = true},
  },
  VERSION_CONTROL = {
    GIT = {
      { "git",         enabled = true }, -- git basic support
      -- {"gitsigns", enabled = true},
      -- {"vgit", enabled = true},
      { "diffview",    enabled = true },    -- git diffview integration
      -- {"repo_search", enabled = true},
      { "github_octo", enabled = true },
      -- {"github_litee", enabled = true},
    },
  },

  -- UI = {
  --   heirline,
  --   fidget,
  --   ...
  -- },
  -- VERSION_CONTROL = {
  --   GIT = {},
  --   GITHUB = {},
  -- },
  LANGS = {
    { "lua",         enabled = true },
    { "python",      enabled = true },
    { "bash",        enabled = true },
    { "fish",        enabled = false },
    { "nu",          enabled = false, tags = { "beta" } },
    { "gdscript",    enabled = false },
    { "gdscript",    enabled = false },
    { "php",         enabled = false },
    { "ruby",        enabled = false },

    -- Web
    { "html",        enabled = true },
    { "javascript",  enabled = true },
    { "typescript",  enabled = true },
    { "css",         enabled = true },
    { "vue",         enabled = true },
    { "tailwindcss", enabled = true },
    { "svelte",      enabled = false },

    -- Compiled
    { "rust",        enabled = true },
    { "cc",          enabled = true },
    { "ocaml",       enabled = false },
    { "haskell",     enabled = false },

    -- JIT
    { "c_sharp",     enabled = false },
    { "kotlin",      enabled = false },
    { "java",        enabled = false },

    { "json",        enabled = true },
    { "yaml",        enabled = false },
    { "toml",        enabled = false },
    { "markdown",    enabled = true },
    { "terraform",   enabled = false },   -- Terraform / hcl files support
    { "dockerfile",  enabled = true },
    { "nix",         enabled = false },   -- Nix declarations
  },

  -- NOTE: move all these into a module called various color schemes
  THEMES = {
    -- Themes designed for neovim
    NVIM = {
      -- {"apprentice", enabled = true},
      -- {"aurora", enabled = true},
      -- {"cassiopeia", enabled = true},
      -- {"catppuccin", enabled = true},
      -- {"github", enabled = true},
      -- {"gruvbox", enabled = true},
      -- {"gruvbuddy", enabled = true},
      -- {"material", enabled = true},
      -- {"monochrome", enabled = true},
      -- {"monokai", enabled = true},
      -- {"moonlight", enabled = true},
      -- {"neon", enabled = true},
      { "nightfox",   enabled = true },
      -- {"nord", enabled = true},
      -- {"nvcode", enabled = true},
      -- {"nvim_deus", enabled = true},
      -- {"oak", enabled = true},
      -- {"oceanic_next", enabled = true},
      -- {"one", enabled = true},
      -- {"onedark", enabled = true},
      -- {"onenord", enabled = true},
      -- {"roshivim", enabled = true},
      -- {"solarized", enabled = true},
      -- {"sonokai", enabled = true},
      -- {"spaceduck", enabled = true},
      -- {"starry", enabled = true},
      -- {"sunflower", enabled = true},
      { "tokyonight", enabled = true },
      -- {"vscode", enabled = true},
      -- {"base16", enabled = true},
      -- {"blue_moon", enabled = true},
      -- {"boo", enabled = true},
      -- {"calvera", enabled = true},
      -- {"catpuccino", enabled = true},
      -- {"cobalt", enabled = true},
      -- {"codeschool", enabled = true},
      -- {"dracula", enabled = true},
      -- {"edge", enabled = true},
      -- {"everforest", enabled = true},
      -- {"falcon", enabled = true},
      -- {"gloombuddy", enabled = true},
      -- "gruvbox-baby",
      -- "gruvbox-material",
      -- {"hybrid", enabled = true},
      -- {"jellybeans", enabled = true},
      -- {"kanagawa", enabled = true},
      -- {"kosmikoa", enabled = true},
      -- {"kyoto", enabled = true},
      -- {"modus", enabled = true},
      -- {"nordic", enabled = true},
      -- {"one_monokai", enabled = true},
      -- {"onebuddy", enabled = true},
      -- {"onedarkpro", enabled = true},
      -- {"papadark", enabled = true},
      -- {"rasmus", enabled = true},
      -- {"rdark", enabled = true},
      -- {"space", enabled = true},
      -- {"substrata", enabled = true},
      -- {"tokyodark", enabled = true},
      -- {"uwu", enabled = true},
      -- {"vim_code_dark", enabled = true},
      -- {"vimdark", enabled = true},
      -- {"vn_night", enabled = true},
      -- {"xresources", enabled = true},
      -- {"zenbones", enabled = true},
      -- {"zephyr", enabled = true},
      -- {"zephyrium", enabled = true},
    },
    -- Themes designed for original Vim
    VIM = {
      -- {"ariake", enabled = true},
      -- {"iceberg", enabled = true},
      -- {"tender", enabled = true},
      { "fly", enabled = true },
      -- {"aquarium", enabled = true},
      -- {"omni", enabled = true},
    },
  },
  MOVE_TO_CORE = {},
  MOLLEWEIDE = {
    { "binds_personal",    enabled = true },
    { "reaper",            enabled = true },
    { "tamton_essentials", enabled = true, tags = { "beta" } },
    { "tweak",             enabled = true },
    { "dorothy",           enabled = true },
    { "plugins_reloader",  enabled = true, tags = { "beta" } },    -- Watch local packages for changes during development
    { "nvim_dev_binds",    enabled = true },
  },
}

-- vim: sw=2 sts=2 ts=2 fdm=indent expandtab
