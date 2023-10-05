local terminal = {}

-- CONFIG EXAMPLE
--
-- require("toggleterm").setup{
--   -- size can be a number or function which is passed the current terminal
--   size = 20 | function(term)
--     if term.direction == "horizontal" then
--       return 15
--     elseif term.direction == "vertical" then
--       return vim.o.columns * 0.4
--     end
--   end,
--   open_mapping = [[<c-\>]],
--   on_create = fun(t: Terminal), -- function to run when the terminal is first created
--   on_open = fun(t: Terminal), -- function to run when the terminal opens
--   on_close = fun(t: Terminal), -- function to run when the terminal closes
--   on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
--   on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
--   on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
--   hide_numbers = true, -- hide the number column in toggleterm buffers
--   shade_filetypes = {},
--   autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
--   highlights = {
--     -- highlights which map to a highlight group name and a table of it's values
--     -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
--     Normal = {
--       guibg = "<VALUE-HERE>",
--     },
--     NormalFloat = {
--       link = 'Normal'
--     },
--     FloatBorder = {
--       guifg = "<VALUE-HERE>",
--       guibg = "<VALUE-HERE>",
--     },
--   },
--   shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
--   shading_factor = '<number>', -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
--   start_in_insert = true,
--   insert_mappings = true, -- whether or not the open mapping applies in insert mode
--   terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
--   persist_size = true,
--   persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
--   direction = 'vertical' | 'horizontal' | 'tab' | 'float',
--   close_on_exit = true, -- close the terminal window when the process exits
--    -- Change the default shell. Can be a string or a function returning a string
--   shell = vim.o.shell,
--   auto_scroll = true, -- automatically scroll to the bottom on terminal output
--   -- This field is only relevant if direction is set to 'float'
--   float_opts = {
--     -- The border key is *almost* the same as 'nvim_open_win'
--     -- see :h nvim_open_win for details on borders however
--     -- the 'curved' border is a custom border type
--     -- not natively supported but implemented in this plugin.
--     border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
--     -- like `size`, width and height can be a number or function which is passed the current terminal
--     width = <value>,
--     height = <value>,
--     winblend = 3,
--     zindex = <value>,
--   },
--   winbar = {
--     enabled = false,
--     name_formatter = function(term) --  term: Terminal
--       return term.name
--     end
--   },
-- }


terminal.settings = {
  size = 10,
  open_mapping = "<F4>",
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  start_in_insert = true,
  persist_size = true,
  direction = "horizontal",
  close_on_exit = true,
  float_opts = {
    border = "curved",
    width = 70,
    height = 20,
    winblend = 0,
    highlights = {
      border = "Special",
      background = "Normal",
    },
  },
}

-- https://github.com/rockerBOO/awesome-neovim#terminal-integration
--
-- https://github.com/zbirenbaum/nvim-chadterm
-- https://github.com/oberblastmeister/termwrapper.nvim
--
--
-- LoricAndre/OneTerm.nvim - Plugin framework for running commands in the terminal.
-- nikvdp/neomux - Control Neovim from shells running inside Neovim.
-- akinsho/nvim-toggleterm.lua - A Neovim Lua plugin to help easily manage multiple terminal windows.
-- norcalli/nvim-terminal.lua - A high performance filetype mode for Neovim which leverages conceal and highlights your buffer with the correct color codes.
-- numToStr/FTerm.nvim - No nonsense floating terminal written in Lua.
-- oberblastmeister/termwrapper.nvim - Wrapper for Neovim's terminal features to make them more user friendly.
-- pianocomposer321/consolation.nvim - A general-purpose terminal wrapper and management plugin for Neovim, written in Lua.
-- jghauser/kitty-runner.nvim - Poor man's REPL. Easily send buffer lines and commands to a kitty terminal.
-- jlesquembre/nterm.nvim - A Neovim plugin to interact with the terminal, with notifications.
-- s1n7ax/nvim-terminal - A simple & easy to use multi-terminal plugin.
terminal.packages = {
  ["toggleterm.nvim"] = {
    "akinsho/toggleterm.nvim",
    commit = "a54e6c471ce1cd8ef8357e34598a28a955297131",
    cmd = { "ToggleTerm", "TermExec" },
    lazy = true,
  },
}

terminal.configs = {}
terminal.configs["toggleterm.nvim"] = function()
  require("toggleterm").setup(doom.features.terminal.settings)
end

-- local function toggle_term_custom()
--   if doom.settings.term_exec_cmd == "" then
--     vim.cmd("ToggleTerm")
--   else
--     local cmd = string.format("TermExec cmd=\"%s\"", doom.settings.term_exec_cmd)
--     vim.cmd(cmd)
--   end
-- end

terminal.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "o",
      name = "+open/close",
      {
        "t", name = "+terminal",{
          -- toggle 1
          { "m", function()
          end, name = "Term Toggle 1" },
          -- toggle 2
          { ",", function()
          end, name = "Term Toggle 2" },
          -- toggle 3
          { ".", function()
          end, name = "Term Toggle 3" },
          -- toggle all - a
          { "a", function()
          end, name = "Term Toggle All" },
          -- toggle lazy git - gTerm Toggle 1
          { "g", function()
          end, name = "TgTerm lazygit" },
          -- term select - s
          { "s", function()
          end, name = "Term Select" },
          -- term set name - r
          { "r", function()
          end, name = "Term Rename" },
          -- send cur line
          -- send vis lines
          -- send vis sel
          { "e", function()
            if doom.settings.term_exec_cmd == "" then
              vim.cmd("ToggleTerm")
            else
              local exec_cmd = string.format("TermExec cmd=\"%s\"", doom.settings.term_exec_cmd)
              vim.cmd(exec_cmd)
            end
          end, name = "Term Exec Zshil" },
      }, },
    },
  },
}

return terminal
