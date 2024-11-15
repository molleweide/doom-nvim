local log = require("doom.utils.logging")
local utils = require("doom.utils")

-- NOTE: help autocmd-pattern

-- TODO: Add a nice buffer header.

local autocmds_service = require("doom.services.autocommands")

-- TODO: Add feature run server job and continuesly listen into a buffer.

local M = {}

M.buffer_monitors_namespace = "MONITOR"

-- NOTE: I can use the clear key to reset all existing autocmds for a namespace.

-- vim.api.nvim_create_augroup(M.buffer_monitors_namespace, { clear = true })

M.spawn_buffer_monitor = function(opts)
  opts = opts or {}

  vim.api.nvim_create_augroup(M.buffer_monitors_namespace, { clear = true })

  local complete_name_string =
      string.format("%s [[[%s]]]: %s", M.buffer_monitors_namespace, opts.name, opts.description)

  if not opts.buf then
    -- Filter lists of all shown/hidden bufs
    local get_ls = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
    end, vim.api.nvim_list_bufs())

    local complete_name_string_escaped = utils.escape_str(complete_name_string)

    -- print("ESCAPED = ", complete_name_string_escaped)

    -- If name match assign use for opts.buf
    vim.tbl_map(function(id)
      local full_buf_name = vim.api.nvim_buf_get_name(id)

      -- print(
      --   "??",
      --   complete_name_string,
      --   full_buf_name:match(string.format("%s$", complete_name_string_escaped))
      -- )

      if
          complete_name_string
          == full_buf_name:match(string.format("%s$", complete_name_string_escaped))
      then
        log.debug(
          string.format(
            "MONITOR: buf w/custom name [%s] already exists!",
            complete_name_string
          )
        )
        opts.buf = id
      end
    end, get_ls)
  end

  if not opts.buf then
    local buf = vim.api.nvim_create_buf(true, true)
    -- -- set the name of the new buf
    vim.api.nvim_buf_set_name(buf, complete_name_string)
    vim.api.nvim_open_win(buf, false, {
      split = "right",
      -- win = 0,
    })
    opts.buf = buf
  end

  print(vim.inspect(opts))

  local header = {
    string.rep("/", complete_name_string:len() + 6),
    string.format("// %s //", complete_name_string),
    string.rep("/", complete_name_string:len()+6),
    "",
    "``````",
  }

  local append_data_callback = function(_, data)
    -- print("MONITOR DATA = ", vim.inspect(data))
    if data then
      table.insert(data,"``````")
      vim.api.nvim_buf_set_lines(opts.buf, #header, -1, false, data)
    end
  end

  if true then
    autocmds_service.set("BufWritePost", opts.pattern, function()
      vim.api.nvim_buf_set_lines(opts.buf, 0, -1, false, header)

      vim.api.nvim_buf_set_lines(opts.buf, #header, -1, false, { "loading.." })
      -- append_data_callback(_, { " loading..."})

      if type(opts.command) == "table" then
        vim.fn.jobstart(opts.command, {
          stdout_buffered = true,
          on_stdout = append_data_callback,
          on_stderr = append_data_callback,
        })
      elseif type(opts.command) == "function" then
        -- FIX: pcall func -> if errors, then catch errs.
        --
        local ret = opts.command(_G[opts.args])

        -- print("ret messages =",vim.inspect(ret.messages))
        -- print("post post post post")

        append_data_callback(_, ret.messages)
      else
        print("(monitor !!!!!!! no command match)")
      end
    end, {
      group = M.buffer_monitors_namespace,
      desc = string.format("%s : %s", opts.name, opts.description),
    })
  end
end

M.cmds = {
  {
    "DoomAddBufferMonitor",
    function()
      -- all of these user inputs should prolly go into the spawn_ func so that
      -- it always falls back to asking the user??
      M.spawn_buffer_monitor({
        name = vim.fn.input("Job name: "),
        buf = tonumber(
          vim.fn.input("Bufnr (<empty> for new buf|`,` for select existing bufs): ")
        ),
        pattern = vim.fn.input("Pattern (% for curr file|<empty> for select file): "),
        command = vim.fn.input("Command: "),
        description = vim.fn.input("Job description: "),
        dry_run = true,
      })
    end,
  },
  {
    -- TODO: add M.__doom_debug_binds = { module_path, keybind }, so that this
    -- can be dynamically updated when selecting a bind and file from within the
    -- nest/main func.
    "DoomDebugBinds",
    -- desc = [[What does this command do??]],
    function()
      -- apply changes to new buffer from name
      M.spawn_buffer_monitor({
        name = "Debug Binds",
        -- NOTE: source/watch patterns
        -- TODO: if no pattern supplied -> user input.
        -- % for current file, <empty> for select file in current repo.
        -- pattern = "%",
        -- pattern = "/Users/hjalmarjakobsson/code/repos/github.com/molleweide/doom-nvim/lua/doom/modules/core/nest/mapper/main.lua",
        pattern = "lua/doom/modules/core/nest/mapper/main.lua",

        -- This needs to be a middleman func so that we can dynamically update
        -- and reset the target function
        command = function(...)
          return require("doom.modules.core.nest.mapper.main").get_match_for_keybind(...)
        end,
        description = 'require("doom.modules.core.nest.mapper.main").get_match_for_keybind',

        -- Specify which global variable that hosts the dynamically set
        -- input args to test for.
        args = "__monitor_doom_debug_binds",
      })
    end,
  },
}

return M
