-- copy paste everything from TJs config to here.


-- TODO:
--
--  - i should try opening tmux new pane or session from within a telescope picker

--
-- FUNCTIONS
--


SHOULD_RELOAD_TELESCOPE = true
local reloader = function()
  if SHOULD_RELOAD_TELESCOPE then
    RELOAD "plenary"
    RELOAD "telescope"
    RELOAD "tj.telescope.setup"
    RELOAD "tj.telescope.custom"
  end
end

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local set_prompt_to_entry_value = function(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  if not entry or not type(entry) == "table" then
    return
  end

  action_state.get_current_picker(prompt_bufnr):reset_prompt(entry.ordinal)
end

local _ = pcall(require, "nvim-nonicons")

local M = {}

-- TODO: modify this one to use doom system vars
function M.edit_neovim()
  local opts_with_preview, opts_without_preview

  opts_with_preview = {
    prompt_title = "~ dotfiles ~",
    shorten_path = false,
    cwd = "~/.config/nvim",

    layout_strategy = "flex",
    layout_config = {
      width = 0.9,
      height = 0.8,

      horizontal = {
        width = { padding = 0.15 },
      },
      vertical = {
        preview_height = 0.75,
      },
    },

    mappings = {
      i = {
        ["<C-y>"] = false,
      },
    },

    attach_mappings = function(_, map)
      map("i", "<c-y>", set_prompt_to_entry_value)
      map("i", "<M-c>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        vim.schedule(function()
          require("telescope.builtin").find_files(opts_without_preview)
        end)
      end)

      return true
    end,
  }

  opts_without_preview = vim.deepcopy(opts_with_preview)
  opts_without_preview.previewer = false

  require("telescope.builtin").find_files(opts_with_preview)
end

-- function M.sourcegraph_find()
--   require("telescope.builtin").find_files {
--     prompt_title = "~ sourcegraph ~",
--     shorten_path = false,
--     cwd = "~/sourcegraph/",
--
--     layout_strategy = "horizontal",
--     layout_config = {
--       width = 0.25,
--       preview_width = 0.65,
--     },
--   }
-- end

-- function M.sourcegraph_main_find()
--   require("telescope.builtin").find_files {
--     prompt_title = "~ main: sourcegraph ~",
--     shorten_path = false,
--     cwd = "~/sourcegraph/sourcegraph.git/main/",
--
--     layout_strategy = "horizontal",
--     layout_config = {
--       width = 0.95,
--       preview_width = 0.65,
--     },
--   }
-- end
--
-- function M.sourcegraph_about_find()
--   require("telescope.builtin").find_files {
--     prompt_tiles = [[\ Sourcegraph About: Files /]],
--     cwd = "~/sourcegraph/about/handbook/",
--
--     sorter = require("telescope").extensions.fzy_native.native_fzy_sorter(),
--   }
-- end
--
-- function M.sourcegraph_about_grep()
--   require("telescope.builtin").live_grep {
--     prompt_tiles = [[\ Sourcegraph About: Files /]],
--     cwd = "~/sourcegraph/about/",
--
--     -- sorter = require('telescope').extensions.fzy_native.native_fzy_sorter(),
--   }
-- end

-- TODO: Should work on a wiki at some point....
--function M.sourcegraph_tips()
--  -- TODO: Can make this optionally fuzzy find over the contents as well
--  --    if we want to start getting fancier
--  --
--  --    Could even make it do that _only_ when doing something like ";" or similar.

--  require('telescope.builtin').find_files {
--    prompt_title = "~ sourcegraph ~",
--    shorten_path = false,
--    cwd = "~/wiki/sourcegraph/tips",
--    width = .25,

--    layout_strategy = 'horizontal',
--    layout_config = {
--      preview_width = 0.65,
--    },
--  }
--end

function M.edit_zsh()
  require("telescope.builtin").find_files {
    shorten_path = false,
    cwd = "~/.config/zsh/",
    prompt = "~ dotfiles ~",
    hidden = true,

    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.55,
    },
  }
end

function M.find_files()
  -- local opts = themes.get_ivy {
  --   hidden = false,
  --   sorting_strategy = "ascending",
  --   layout_config = { height = 9 },
  -- }
  require("telescope.builtin").find_files {
    sorting_strategy = "descending",
    scroll_strategy = "cycle",
    layout_config = {
      -- height = 10,
    },
  }
end

-- TODO: use this one
function M.fs()
  local opts = themes.get_ivy { hidden = false, sorting_strategy = "descending" }
  require("telescope.builtin").find_files(opts)
end

-- NOTE: what is this?
function M.builtin()
  require("telescope.builtin").builtin()
end

-- NOTE: what is this?
function M.git_files()
  local path = vim.fn.expand "%:h"
  if path == "" then
    path = nil
  end

  local width = 0.75
  if path and string.find(path, "sourcegraph.*sourcegraph", 1, false) then
    width = 0.5
  end

  local opts = themes.get_dropdown {
    winblend = 5,
    previewer = false,
    shorten_path = false,

    cwd = path,

    layout_config = {
      width = width,
    },
  }

  require("telescope.builtin").git_files(opts)
end

function M.buffer_git_files()
  require("telescope.builtin").git_files(themes.get_dropdown {
    cwd = vim.fn.expand "%:p:h",
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  })
end

function M.lsp_code_actions()
  local opts = themes.get_dropdown {
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  }

  require("telescope.builtin").lsp_code_actions(opts)
end

function M.live_grep()
  require("telescope.builtin").live_grep {
    -- shorten_path = true,
    previewer = false,
    fzf_separator = "|>",
  }
end

function M.grep_prompt()
  require("telescope.builtin").grep_string {
    path_display = { "shorten" },
    search = vim.fn.input "Grep String > ",
  }
end

function M.grep_last_search(opts)
  opts = opts or {}

  -- \<getreg\>\C
  -- -> Subs out the search things
  local register = vim.fn.getreg("/"):gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", "")

  opts.path_display = { "shorten" }
  opts.word_match = "-w"
  opts.search = register

  require("telescope.builtin").grep_string(opts)
end

function M.oldfiles()
  require("telescope").extensions.frecency.frecency(themes.get_ivy {})
end

function M.my_plugins()
  require("telescope.builtin").find_files {
    cwd = "~/plugins/",
  }
end

function M.installed_plugins()
  require("telescope.builtin").find_files {
    cwd = vim.fn.stdpath "data" .. "/site/pack/packer/start/",
  }
end

function M.project_search()
  require("telescope.builtin").find_files {
    previewer = false,
    layout_strategy = "vertical",
    cwd = require("nvim_lsp.util").root_pattern ".git"(vim.fn.expand "%:p"),
  }
end

function M.buffers()
  require("telescope.builtin").buffers {
    shorten_path = false,
  }
end

function M.curbuf()
  local opts = themes.get_dropdown {
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  }
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

function M.help_tags()
  require("telescope.builtin").help_tags {
    show_version = true,
  }
end

function M.search_all_files()
  require("telescope.builtin").find_files {
    find_command = { "rg", "--no-ignore", "--files" },
  }
end

function M.example_for_prime()
  -- local Sorter = require('telescope.sorters')

  -- require('telescope.builtin').find_files {
  --   sorter = Sorter:new {
  -- }
end

function M.file_browser()
  local opts

  opts = {
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
    layout_config = {
      prompt_position = "top",
    },

    attach_mappings = function(prompt_bufnr, map)
      local current_picker = action_state.get_current_picker(prompt_bufnr)

      local modify_cwd = function(new_cwd)
        local finder = current_picker.finder

        finder.path = new_cwd
        finder.files = true
        current_picker:refresh(false, { reset_prompt = true })
      end

      map("i", "-", function()
        modify_cwd(current_picker.cwd .. "/..")
      end)

      map("i", "~", function()
        modify_cwd(vim.fn.expand "~")
      end)

      -- local modify_depth = function(mod)
      --   return function()
      --     opts.depth = opts.depth + mod
      --
      --     current_picker:refresh(false, { reset_prompt = true })
      --   end
      -- end
      --
      -- map("i", "<M-=>", modify_depth(1))
      -- map("i", "<M-+>", modify_depth(-1))

      map("n", "yy", function()
        local entry = action_state.get_selected_entry()
        vim.fn.setreg("+", entry.value)
      end)

      return true
    end,
  }

  require("telescope").extensions.file_browser.file_browser(opts)
end

function M.git_status()
  local opts = themes.get_dropdown {
    winblend = 10,
    border = true,
    previewer = false,
    shorten_path = false,
  }

  -- Can change the git icons using this.
  -- opts.git_icons = {
  --   changed = "M"
  -- }

  require("telescope.builtin").git_status(opts)
end

function M.git_commits()
  require("telescope.builtin").git_commits {
    winblend = 5,
  }
end

function M.search_only_certain_files()
  require("telescope.builtin").find_files {
    find_command = {
      "rg",
      "--files",
      "--type",
      vim.fn.input "Type: ",
    },
  }
end

function M.lsp_references()
  require("telescope.builtin").lsp_references {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    ignore_filename = false,
  }
end

function M.lsp_implementations()
  require("telescope.builtin").lsp_implementations {
    layout_strategy = "vertical",
    layout_config = {
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    ignore_filename = false,
  }
end

function M.vim_options()
  require("telescope.builtin").vim_options {
    layout_config = {
      width = 0.5,
    },
    sorting_strategy = "ascending",
  }
end

return setmetatable({}, {
  __index = function(_, k)
    reloader()

    local has_custom, custom = pcall(require, string.format("tj.telescope.custom.%s", k))

    if M[k] then
      return M[k]
    elseif has_custom then
      return custom
    else
      return require("telescope.builtin")[k]
    end
  end,
})


--
-- MAPPINGS
--


if not pcall(require, "telescope") then
  return
end

local sorters = require "telescope.sorters"

TelescopeMapArgs = TelescopeMapArgs or {}

local map_tele = function(key, f, options, buffer)
  local map_key = vim.api.nvim_replace_termcodes(key .. f, true, true, true)

  TelescopeMapArgs[map_key] = options or {}

  local mode = "n"
  local rhs = string.format("<cmd>lua R('tj.telescope')['%s'](TelescopeMapArgs['%s'])<CR>", f, map_key)

  local map_options = {
    noremap = true,
    silent = true,
  }

  if not buffer then
    vim.api.nvim_set_keymap(mode, key, rhs, map_options)
  else
    vim.api.nvim_buf_set_keymap(0, mode, key, rhs, map_options)
  end
end

vim.api.nvim_set_keymap("c", "<c-r><c-r>", "<Plug>(TelescopeFuzzyCommandSearch)", { noremap = false, nowait = true })

-- Dotfiles
map_tele("<leader>en", "edit_neovim")
map_tele("<leader>ez", "edit_zsh")
map_tele("<space><space>d", "diagnostics")

-- Search
-- TODO: I would like to completely remove _mock from my search results here when I'm in SG/SG
map_tele("<space>gw", "grep_string", {
  short_path = true,
  word_match = "-w",
  only_sort_text = true,
  layout_strategy = "vertical",
  sorter = sorters.get_fzy_sorter(),
})
map_tele("<space>f/", "grep_last_search", {
  layout_strategy = "vertical",
})

-- Files
map_tele("<space>ft", "git_files")
-- map_tele("<space>fg", "live_grep")
map_tele("<space>fg", "multi_rg")
map_tele("<space>fo", "oldfiles")
map_tele("<space>fd", "find_files")
map_tele("<space>fs", "fs")
map_tele("<space>pp", "project_search")
map_tele("<space>fv", "find_nvim_source")
map_tele("<space>fe", "file_browser")
map_tele("<space>fz", "search_only_certain_files")

-- Sourcegraph
map_tele("<space>sf", "sourcegraph_find")
map_tele("<space>saf", "sourcegraph_about_find")
map_tele("<space>sag", "sourcegraph_about_grep")
-- map_tele('<space>fz', 'sourcegraph_tips')

-- Git
map_tele("<space>gs", "git_status")
map_tele("<space>gc", "git_commits")

-- Nvim
map_tele("<space>fb", "buffers")
map_tele("<space>fp", "my_plugins")
map_tele("<space>fa", "installed_plugins")
map_tele("<space>fi", "search_all_files")
map_tele("<space>ff", "curbuf")
map_tele("<space>fh", "help_tags")
map_tele("<space>bo", "vim_options")
map_tele("<space>gp", "grep_prompt")
map_tele("<space>wt", "treesitter")

-- Telescope Meta
map_tele("<space>fB", "builtin")

return map_tele

