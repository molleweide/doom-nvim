local log = require("doom.utils.logging")
local utils = require("doom.utils")

local autocmds_service = require("doom.services.autocommands")

-- TODO: hide monitor bufs -> add doom keybind to access the monitor
-- bufs. with custom keybinds to handle them.

-- NOTE: help autocmd-pattern
-- NOTE: help luv.txt.
-- TODO: Add feature run server job and continuesly listen into a buffer.
-- NOTE: I can use the clear key to reset all existing autocmds for a namespace.

--NOTE: patterns
-- autocmd event  ->  lua func  -> buffer
-- autocmd event  ->  job       -> buffer
-- watch changes  ->            -> buffer
-- server                       -> buffer

local M = {}

-- makaze watch does a lot of the things that I have wanted here.
-- M.packages = {
--   ["ast"] = { "Makaze/watch.nvim" },
--   https://github.com/rktjmp/fwatch.nvim
-- }

M.buffer_monitors_namespace = "MONITOR"
-- vim.api.nvim_create_augroup(M.buffer_monitors_namespace, { clear = true })

-- reset autocmds and remove buffers
M.reset = function()
  vim.api.nvim_create_augroup(M.buffer_monitors_namespace, { clear = true })
  -- todo remove bufs
  -- TODO: 1. get all bufs matching the namespace prefix,
  -- 2. kill all these bufs
  --
end

M.spawn_buffer_monitor = function(opts)
  opts = opts or {}

  -- TODO: should show X -> Y, so that I can display a short eg. filename for
  -- the source pattern and what it is running/calling that will then project
  -- into the monitor buffer.
  local instance_name =
      string.format("%s [[[%s]]]: %s", M.buffer_monitors_namespace, opts.name, opts.description)

  -- Filter lists of all shown/hidden bufs
  if not opts.buf then
    local complete_name_string_escaped = utils.escape_str(instance_name)

    -- mv >> Utils get bufs
    local get_ls = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted")
    end, vim.api.nvim_list_bufs())

    -- mv >> Utils get buf with name XYZ, or create new handle with name..
    vim.tbl_map(function(id)
      local full_buf_name = vim.api.nvim_buf_get_name(id)
      if
          instance_name
          == full_buf_name:match(string.format("%s$", complete_name_string_escaped))
      then
        log.debug(
          string.format("MONITOR: buf w/custom name [%s] already exists!", instance_name)
        )
        opts.buf = id
      end
    end, get_ls)
  end

  -- create new buf
  if not opts.buf then
    local buf = vim.api.nvim_create_buf(true, true)

    vim.api.nvim_buf_set_name(buf, instance_name)

    vim.api.nvim_open_win(buf, false, { split = "left" })
    opts.buf = buf
  end

  local header = {
    string.rep("/", instance_name:len() + 6),
    string.format("// %s //", instance_name),
    string.rep("/", instance_name:len() + 6),
    "",
    "``````",
  }

  local append_data_callback = function(_, data)
    if data then
      if type(data) == "string" then
        data = vim.split(data, "\n")
      end
      table.insert(data, "``````")
      vim.api.nvim_buf_set_lines(opts.buf, #header, -1, false, data)
    end
  end

  -- FIX: If the buf has been accedientally removed/deleted, then just
  -- recreate the buffer and reassign.

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
        -- How to handle if there is no args passed or if
        -- result is nil?

        local ok, result = xpcall(opts.command, debug.traceback, _G[opts.args])
        if not ok then
          append_data_callback(_, result)
        else
          append_data_callback(_, result.messages)
        end
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
    -- RENAME: monitor module func??
    "DoomDebugBinds",
    function()
      M.spawn_buffer_monitor({
        name = "Debug Binds",
        description = "Helper when building the binds leaf finder.",
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
        -- Specify which global variable that hosts the dynamically set
        -- input args to test for.
        args = "__monitor_doom_debug_binds",
      })
    end,
  },
  {
    "MonitorRealTimeData",
    function()
      -- https://github.com/bytewax/awesome-public-real-time-datasets
      --
      -- https://ably.com/blog/10-realtime-data-sources-you-wont-believe-are-free
      -- https://rapidapi.com/collection/real-time
      -- TODO: setup an interval timer that regularly calls the apis for data
      -- and monitors into a buffer.
      --
      -- TODO: Use https://github.com/rest-nvim/rest.nvim
      -- to perform the http requests.
      -- Rest has an awesome api and system for performing http requests
      -- so that we can integrate the internet in this shit.
      -- dependincies: https://github.com/rest-nvim/rest.nvim/tree/main?tab=readme-ov-file#dependencies
    end,
  },
  {
    "ReaperMonitorLogging",
    function()
      -- reaper has to send the information. Here we setup a listener that
      -- then prints the logging data to the buffer.
    end,
  },
  {
    "MonitorSystemProcess",
    function()
      -- Use nio.process to interact with a running process.
      --
    end,
  },
  {
    "DoomResetMonitors",
    function()
      M.reset()
    end,
  },
}

return M
