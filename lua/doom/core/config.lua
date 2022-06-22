--  doom.core.config
--
--  Responsible for setting some vim global defaults, managing the `doom.field_name`
--  config options, pre-configuring the user's modules from `modules.lua`, and
--  running the user's `config.lua` file.

local utils = require("doom.utils")
local system = require("doom.core.system")
local config = {}
local filename = "config.lua"

config.source = nil


--- Entry point to bootstrap doom-nvim.
config.load = function()
  -- Set vim defaults on first load. To override these, the user can just
  -- override vim.opt in their own config, no bells or whistles attached.
  vim.opt.hidden = true
  vim.opt.updatetime = 200
  vim.opt.timeoutlen = 400
  vim.opt.background = "dark"
  vim.opt.completeopt = {
    "menu",
    "menuone",
    "preview",
    "noinsert",
    "noselect",
  }
  vim.opt.shortmess = "atsc"
  vim.opt.inccommand = "split"
  vim.opt.path = "**"
  vim.opt.signcolumn = "auto:2-3"
  vim.opt.foldcolumn = "auto:9"
  vim.opt.colorcolumn = "80"
  vim.opt.formatoptions:append("j")
  vim.opt.fillchars = {
    vert = "▕",
    fold = " ",
    eob = " ",
    diff = "─",
    msgsep = "‾",
    foldopen = "▾",
    foldclose = "▸",
    foldsep = "│",
  }
  vim.opt.smartindent = true
  vim.opt.copyindent = true
  vim.opt.preserveindent = true
  vim.opt.clipboard = "unnamedplus"
  vim.opt.cursorline = true
  vim.opt.splitright = false
  vim.opt.splitbelow = true
  vim.opt.scrolloff = 4
  vim.opt.showmode = false
  vim.opt.mouse = "a"
  vim.opt.wrap = false
  vim.opt.swapfile = false
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.expandtab = true
  vim.opt.conceallevel = 0
  vim.opt.foldenable = true
  vim.opt.foldtext = require("doom.core.functions").sugar_folds()

 -- Combine enabled modules (`modules.lua`) with core modules.
  local enabled_modules = require("doom.core.modules").enabled_modules

  --- Attach each module to the global `doom.modules` table
  ---@param tp    table of a modules path components
  ---@param res   the required results that should be attached to
  local head -- is it a bad pattern to keep head like this?
  local function attach_modules(tp,res)
    head = doom.modules
    local last = #tp
    for i, p in ipairs(tp) do
      if i ~= last then
        if head[p] == nil then
          head[p] = {}
        end
        head = head[p]
      else
        head[p] = res
      end
    end
  end

  --- Require each enabled module.
  ---@param t_path is a table of path components for each respective module
  local function require_modules(t_path)
    local path_concat = table.concat(t_path, ".")
    local search_paths = {
      ("user.modules.%s"):format(path_concat),
      ("doom.modules.%s"):format(path_concat)
    }
    local ok, result
    for _, path in ipairs(search_paths) do
      ok, result = xpcall(require, debug.traceback, path)
      if ok then
        break;
      end
    end
    if ok then
      attach_modules(t_path, result)
    else
      local log = require("doom.utils.logging")
      log.error(
        string.format(
          "There was an error loading module '%s'. Traceback:\n%s",
          path_concat,
          result
        )
      )
    end
  end

  --- Recursively crawl the modules tree and require each leaf module.
  ---@param modules_tree  enabled modules table
  ---@param stack         stack to keep track of each module path
  local function recurse_modules(modules_tree, stack)
    local stack = stack or {}
    for k, v in pairs(modules_tree) do
      if type(v) == "table" then
        table.insert(stack, k)
        recurse_modules(v, stack)
      else
        local pc = { v }
        if #stack > 0 then
          pc = vim.deepcopy(stack)
          table.insert(pc, v)
        end
        require_modules(pc)
      end
    end
    table.remove(stack, #stack)
    return
  end

  recurse_modules(enabled_modules)

  -- Execute user's `config.lua` so they can modify the doom global object.
  local ok, err = xpcall(dofile, debug.traceback, config.source)
  local log = require("doom.utils.logging")
  if not ok and err then
    log.error("Error while running `config.lua. Traceback:\n" .. err)
  end

  -- Apply the necessary `doom.field_name` options
  vim.opt.shiftwidth = doom.settings.indent
  vim.opt.softtabstop = doom.settings.indent
  vim.opt.tabstop = doom.settings.indent
  if doom.settings.guicolors then
    if vim.fn.exists("+termguicolors") == 1 then
      vim.opt.termguicolors = true
    elseif vim.fn.exists("+guicolors") == 1 then
      vim.opt.guicolors = true
    end
  end

  if doom.settings.auto_comment then
    vim.opt.formatoptions:append("croj")
  end
  if doom.settings.movement_wrap then
    vim.cmd("set whichwrap+=<,>,[,],h,l")
  end

  if doom.settings.undo_dir then
    vim.opt.undofile = true
    vim.opt.undodir = doom.settings.undo_dir
  else
    vim.opt.undofile = false
    vim.opt.undodir = nil
  end
  vim.g.mapleader = doom.settings.leader_key
end


-- Path cases:
--   1. stdpath('config')/../doom-nvim/config.lua
--   2. stdpath('config')/config.lua
--   3. <runtimepath>/doom-nvim/config.lua
config.source = utils.find_config(filename)
return config
