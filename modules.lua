-- modules.lua - Doom nvim module selection
-- modules.lua controls what Doom nvim plugins modules are enabled and
-- what features are being used.
--
-- Uncomment a plugin to enable it and comment out to disable and uninstall it.
--
-- TODO: Use https://github.com/mtrajano/tssorter.nvim to sort this table
-- automatically.
--
-- TODO: Check if we can define custom rules for how to format this table with
-- luacheck/stylua, eg. so that each module becomes its own line, but all sections
-- are broken up into multiline.

return {
    AI = { { "chat_gpt", enabled = true } },
    LIB = {
        { "nio", enabled = true }, -- asynch IO
        -- "litee"
        -- "libmodal" -- custom pseudo modes | also check out https://github.com/nvimtools/hydra.nvim
        -- https://github.com/jrop/u.nvim/tree/v2
    },
    FEATURES = {
        { "lua_table_editor", enabled = false },
        { "architext", enabled = true },
        { "monitoring", enabled = true },
        { "lsp_progress", enabled = true },
        { "file_explorer_oil", enabled = true },
        BUFFERS = {
            { "buffer_management", enabled = true },
            { "temporary_buffers", enabled = true },
            { "cleanup_unused", enabled = true },
        },
        { "testmodule", enabled = false },
        { "task_and_job_manager", enabled = true },
        LIB = {
            { "litee", enabled = true },
            { "pathlib", enabled = true },
        },
        COMPLETIONS = {
            { "cmp_nvim", enabled = false },
            -- "coc"
        },
        SNIPPETS = {
            { "extra_snippets", enabled = true }, -- Code snippets for all languages
            { "luasnip_engine", enabled = true, tags = { "reduced", "firenvim" } },
            { "additional_friendly_snippets", enabled = true, tags = { "reduced", "firenvim" } },
            { "luasnip_telescope", enabled = true },
        },

        -- Language features
        { "annotations", enabled = true }, -- Code annotation generator
        { "auto_install", enabled = true }, -- Auto install LSP providers
        { "autopairs", enabled = true }, -- Automatically close character pairs
        { "comment", enabled = true }, -- Adds keybinds to comment in any language
        { "linter", enabled = true }, -- Linting and formatting for languages
        { "lsp", enabled = true }, -- Code completion
        { "lsp_cmp", enabled = true },
        { "lsp_signature_hints", enabled = true },
        { "context_in_code", enabled = true },
        { "additional_vim_textobjects", enabled = true },
        LANGUAGE_FEATURES = {
            -- {"virtual_types", enabled = false},
            { "auto_add_end_keyword", enabled = true },
            { "highlight_args_and_params", enabled = true },
            { "preview_edit_and_navigate_lsp_locations", enabled = false },
            { "swap_args_and_elems", enabled = true },
            { "ts_plugins", enabled = true },
        },

        -- TODO: Move all lsp stuff into this directory...
        LSP = {
            { "lspconfig", enabled = false },
        },

        -- Editor
        { "auto_session", enabled = true }, -- Remember sessions between loads
        { "colorizer", enabled = true }, -- Show colors in neovim
        { "editorconfig", enabled = true }, -- Support editorconfig files
        { "gitsigns", enabled = false }, -- Show git changes in sidebar
        { "illuminate", enabled = true }, -- Highlight other copies of the word you're hovering on
        { "indentlines", enabled = true }, -- Show indent lines with special characters
        { "range_highlight", enabled = true }, -- Highlight selected range from commands
        { "todo_comments", enabled = true }, -- Highlight TODO: comments
        { "doom_themes", enabled = true }, -- Extra themes for doom
        { "color_pickers", enabled = true },
        { "clipboard_neoclip", enabled = true },
        { "clipboard_images", enabled = true },
        REFACTOR = { { "refactoring", enabled = true }, "exemplum" },
        { "search_and_replace", enabled = true },
        { "quickfix_improvements", enabled = true },
        { "increment_and_toggle_values", enabled = true },
        { "project_root_and_cwd", enabled = true },
        { "comments_block_headers", enabled = true },
        { "marks", enabled = true },
        { "folds", enabled = true },
        { "help_and_doc_bindings_various", enabled = true }, -- Support for help with binds and stuff
        { "cursor", enabled = true },
        { "formatting", enabled = true },
        EDITOR = {
            { "spellcheck", enabled = false },
            { "surround", enabled = true }, -- Surround text objects, eg. {([])}
            { "gestures", enabled = false }, -- Mouse gestures
            { "tabs", enabled = false }, -- ???
            { "scroll", enabled = true },
            { "registers", enabled = true },
            { "undo_tree_visualization", enabled = true },
            { "printer", enabled = false },
            { "sort", enabled = false }, -- extra binds that help with sorting lines/objects
            { "logging", enabled = false }, -- binds n stuff
            { "litee_symboltree", enabled = false },
            { "litee_bookmarks", enabled = false },
            { "litee_calltree", enabled = false },
            { "code_outline", enabled = false },
            { "readline", enabled = false }, -- ???
            { "editing", enabled = true },
        },

        -- CURSOR MOVEMENT
        { "movement_lightspeed", enabled = true },

        -- UI COMPONENTS
        { "tabline", enabled = true }, -- Tab bar buffer switcher
        { "dashboard", enabled = true }, -- A pretty dashboard upon opening
        { "trouble", enabled = true }, -- A pretty diagnostic viewer
        { "statusline", enabled = true }, -- A pretty status line at the bottom of the buffer
        { "minimap", enabled = false }, -- Shows current position in document

        { "terminal", enabled = true }, -- Integrated terminal in neovim
        TERMINAL = {
            -- TODO: Move terminal related plugins into this dir
        },

        NVIM_HELP = {
            { "vimdoc_and_help_decorations", enabled = true },
        },

        { "symbols_outline_sidebar", enabled = true }, -- Navigate between code symbols using telescope
        { "ranger", enabled = true }, -- File explorer in neovim (TODO: Test)
        { "restclient", enabled = true }, -- Test HTTP requests from neovim (TODO: Test)
        { "show_registers", enabled = true }, -- Show and navigate between registers
        { "dui", enabled = true }, -- [WIP] Managen your doom config with Telescope.
        { "ui_make_transparent", enabled = true },
        { "ui_custom_vim_input_select", enabled = true },
        UI = {
            { "noice_ergonomic_ui", enabled = true },
        },

        -- TOOLS
        { "dap", enabled = true }, -- Debug code through neovim
        { "repl", enabled = true },
        { "email_himalaya", enabled = true },
        { "explorer", enabled = true }, -- An enhanced filetree explorer
        { "firenvim", enabled = true }, -- Embed neovim in your browser
        { "lazygit", enabled = true }, -- Lazy git integration
        { "neogit", enabled = true }, -- A git client for neovim
        { "netrw", enabled = false },
        { "neorg", enabled = true }, -- Organise your life
        { "superman", enabled = true }, -- Read unix man pages in neovim
        { "suda", enabled = true }, -- Save using sudo when necessary
        { "telescope", enabled = true }, -- Fuzzy searcher to find files, grep code and more
        { "telescope_extensions_various", enabled = false },
        { "whichkey", enabled = true, tags = { "reduced", "firenvim" } }, -- An interactive sheet
        { "zen", enabled = true },
        { "music_and_audio_engineering", enabled = true },
        { "figlet", enabled = true },
        { "markup_bindings_and_tools", enabled = true },

        TOOLS = {
            { "spreadsheets", enabled = true },
            { "flutter", enabled = false },
            { "google_docs", enabled = false },
            { "ssh", enabled = false },
            { "open_scad", enabled = false },
            { "docker", enabled = false }, -- Docker tools
            { "pandoc", enabled = false },
            { "remote_dev", enabled = false }, -- ???
            { "gpg", enabled = false },
            { "collaborate", enabled = false }, -- Google docs collaborative editing.
        },

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
            { "center_focused_window", enabled = true },
        },

        WORKSPACE_MANAGEMENT = {
            { "projects", enabled = true }, -- Quickly switch between projects
            { "system_git_repos", enabled = true },
            { "ghq", enabled = true },
        },

        -- TODO: ypc and clipboard should go under `editor`
        -- Rename to `ypc_and_clipboard`
        YANK_PUT_AND_CUT = {
            { "ypc_binds", enabled = true },
            { "yank_cmp_source", enabled = false },
            { "yank_improved", enabled = false },
            { "yank_smart_flow", enabled = false },
        },
    },
    UI = {
        { "sidebar_generic_modular", enabled = false },
    },
    VERSION_CONTROL = {
        GIT = {
            { "git", enabled = true }, -- git basic support
            { "gitsigns", enabled = false },
            { "vgit", enabled = false },
            { "diffview", enabled = true }, -- git diffview integration
            { "repo_search", enabled = false },
            { "github_octo", enabled = true },
            { "github_litee", enabled = false },
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
        { "lua", enabled = true },
        { "python", enabled = true },
        { "bash", enabled = true },
        { "fish", enabled = false },
        { "nu", enabled = false, tags = { "beta" } },
        { "gdscript", enabled = false },
        { "gdscript", enabled = false },
        { "php", enabled = false },
        { "ruby", enabled = false },

        -- Web
        { "html", enabled = true },
        { "javascript", enabled = true },
        { "typescript", enabled = true },
        { "css", enabled = true },
        { "vue", enabled = true },
        { "tailwindcss", enabled = true },
        { "svelte", enabled = false },

        -- Compiled
        { "rust", enabled = true },
        { "cc", enabled = true },
        { "ocaml", enabled = false },
        { "haskell", enabled = false },

        -- JIT
        { "c_sharp", enabled = false },
        { "kotlin", enabled = false },
        { "java", enabled = false },

        { "json", enabled = true },
        { "yaml", enabled = false },
        { "toml", enabled = false },
        { "markdown", enabled = true },
        { "terraform", enabled = false }, -- Terraform / hcl files support
        { "dockerfile", enabled = true },
        { "nix", enabled = false }, -- Nix declarations
    },

    -- NOTE: move all these into a module called various color schemes
    -- [various_neovim_themes] and [various_vim_themes]
    THEMES = {
        -- Themes designed for neovim
        NVIM = {
            { "apprentice", enabled = false },
            { "aurora", enabled = false },
            { "cassiopeia", enabled = false },
            { "catppuccin", enabled = false },
            { "github", enabled = false },
            { "gruvbox", enabled = false },
            { "gruvbuddy", enabled = false },
            { "material", enabled = false },
            { "monochrome", enabled = false },
            { "monokai", enabled = false },
            { "moonlight", enabled = false },
            { "neon", enabled = false },
            { "nightfox", enabled = true },
            { "nord", enabled = false },
            { "nvcode", enabled = false },
            { "nvim_deus", enabled = false },
            { "oak", enabled = false },
            { "oceanic_next", enabled = false },
            { "one", enabled = false },
            { "onedark", enabled = false },
            { "onenord", enabled = false },
            { "roshivim", enabled = false },
            { "solarized", enabled = false },
            { "sonokai", enabled = false },
            { "spaceduck", enabled = false },
            { "starry", enabled = false },
            { "sunflower", enabled = false },
            { "tokyonight", enabled = true },
            { "vscode", enabled = false },
            { "base16", enabled = false },
            { "blue_moon", enabled = false },
            { "boo", enabled = false },
            { "calvera", enabled = false },
            { "catpuccino", enabled = false },
            { "cobalt", enabled = false },
            { "codeschool", enabled = false },
            { "dracula", enabled = false },
            { "edge", enabled = false },
            { "everforest", enabled = false },
            { "falcon", enabled = false },
            { "gloombuddy", enabled = false },
            -- "gruvbox-baby",
            -- "gruvbox-material",
            { "hybrid", enabled = false },
            { "jellybeans", enabled = false },
            { "kanagawa", enabled = false },
            { "kosmikoa", enabled = false },
            { "kyoto", enabled = false },
            { "modus", enabled = false },
            { "nordic", enabled = false },
            { "one_monokai", enabled = false },
            { "onebuddy", enabled = false },
            { "onedarkpro", enabled = false },
            { "papadark", enabled = false },
            { "rasmus", enabled = false },
            { "rdark", enabled = false },
            { "space", enabled = false },
            { "substrata", enabled = false },
            { "tokyodark", enabled = false },
            { "uwu", enabled = false },
            { "vim_code_dark", enabled = false },
            { "vimdark", enabled = false },
            { "vn_night", enabled = false },
            { "xresources", enabled = false },
            { "zenbones", enabled = false },
            { "zephyr", enabled = false },
            { "zephyrium", enabled = false },
        },
        -- Themes designed for original Vim
        VIM = {
            { "ariake", enabled = false },
            { "iceberg", enabled = false },
            { "tender", enabled = false },
            { "fly", enabled = true },
            { "aquarium", enabled = false },
            { "omni", enabled = false },
        },
    },
    MOVE_TO_CORE = {},
    MOLLEWEIDE = {
        { "binds_personal", enabled = true },
        { "reaper", enabled = true },
        { "tamton_essentials", enabled = true, tags = { "beta" } },
        { "tweak", enabled = true },
        { "dorothy", enabled = true },
        { "plugins_reloader", enabled = true, tags = { "beta" } }, -- Watch local packages for changes during development
        { "nvim_dev_binds", enabled = true },
    },
}

-- vim: sw=4 sts=4 ts=4 fdm=indent expandtab
