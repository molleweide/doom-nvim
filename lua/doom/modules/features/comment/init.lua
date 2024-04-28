local comment = {}

comment.state = "stable"

comment.settings = {
  --- Add a space b/w comment and the line
  --- @type boolean
  padding = true,

  --- Whether the cursor should stay at its position
  --- NOTE: This only affects NORMAL mode mappings and doesn't work with dot-repeat
  --- @type boolean
  sticky = true,

  --- Lines to be ignored while comment/uncomment.
  --- Could be a regex string or a function that returns a regex string.
  --- Example: Use '^$' to ignore empty lines
  --- @type string|fun():string
  ignore = nil,

  --     ---LHS of toggle mappings in NORMAL mode
  --     toggler = {
  --         ---Line-comment toggle keymap
  --         line = 'gcc',
  --         ---Block-comment toggle keymap
  --         block = 'gbc',
  --     },

  -- ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  -- opleader = {
  --   ---Line-comment keymap
  --   line = "gc",
  --   ---Block-comment keymap
  --   block = "gb",
  -- },

  --     ---LHS of extra mappings
  --     extra = {
  --         ---Add comment on the line above
  --         above = 'gcO',
  --         ---Add comment on the line below
  --         below = 'gco',
  --         ---Add comment at the end of line
  --         eol = 'gcA',
  --     },

  -- -- NOTE: If given `false` then the plugin won't create any mappings
  -- -- Enable keybindings
  -- mappings = {
  --     ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
  --     basic = true,
  --     ---Extra mapping; `gco`, `gcO`, `gcA`
  --     extra = true,
  -- },

  --- Function to call before (un)comment
  --- Passes to ts-context-commentstring to get commentstring in JSX
  pre_hook = function(ctx)
    -- Only calculate commentstring for tsx filetypes
    if vim.bo.filetype == "typescriptreact" then
      local comment_utils = require("Comment.utils")

      -- Detemine whether to use linewise or blockwise commentstring
      local type = ctx.ctype == comment_utils.ctype.line and "__default" or "__multiline"

      -- Determine the location where to calculate commentstring from
      local location = nil
      if ctx.ctype == comment_utils.ctype.block then
        location = require("ts_context_commentstring.utils").get_cursor_location()
      elseif ctx.cmotion == comment_utils.cmotion.v or ctx.cmotion == comment_utils.cmotion.V then
        location = require("ts_context_commentstring.utils").get_visual_start_location()
      end

      return require("ts_context_commentstring.internal").calculate_commentstring({
        key = type,
        location = location,
      })
    end
  end,

  --     ---Function to call after (un)comment
  --     post_hook = nil,
}

comment.packages = {
  ["Comment.nvim"] = {
    "numToStr/Comment.nvim",
    -- commit = "e89df176e8b38e931b7e71a470f923a317976d86",
  },
}

comment.configs = {}
comment.configs["Comment.nvim"] = function()
  local config = vim.tbl_extend("force", doom.features.comment.settings, {
    -- Disable mappings as we'll handle it in binds.lua
    mappings = {
      basic = false,
      extra = false,
      extended = false,
    },
  })

  require("Comment").setup(config)
end

-- E15: Invalid expression: <80><fd>hlua require("Comment.api").call('toggle.linewise', '@g')^M

-- NOTE: https://github.com/numToStr/Comment.nvim/pull/204
-- @before rhs was = [[<cmd>lua require("Comment.api").call('toggle.linewise', '@g')<CR>]],
--
-- api.call({cb}, {op})                                          *comment.api.call*
--     Callback function which does the following
--       1. Sets 'operatorfunc' for dot-repeat
--       2. Preserves jumps and marks
--       3. Stores last cursor position
--
--     Parameters: ~
--         {cb}  (string)      Name of the API function to call
--         {op}  ("g@"|"g@$")  Operator-mode expression
--
--     Returns: ~
--         (fun():string)  Keymap RHS callback
--
--     See: ~
--         |g@|
--         |operatorfunc|
--
--     Usage: ~
-- >lua
--         local api = require('Comment.api')
--         vim.keymap.set(
--             'n', 'gc', api.call('toggle.linewise', 'g@'),
--             { expr = true }
--         )
--         vim.keymap.set(
--             'n', 'gcc', api.call('toggle.linewise.current', 'g@$'),
--             { expr = true }
--         )
-- <

local function surround_visual_selection_with_jsx_comment()
  local utils = require("doom.utils")

  local vis_sel = utils.get_visual_selection()

  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")

  -- NOTE: [bufnum, lnum, col, off]

  print("start", vim.inspect(s_start))
  print("end", vim.inspect(s_end))

  print(s_start[1])

  if s_start[3] > 1000 then
    return
  end

  local buf = s_start[1]
  local  start_row = s_start[2] - 1
  local  end_row = s_end[2] -1


  vim.api.nvim_buf_set_text(
    buf,
    end_row,
    s_end[3],
    end_row,
    s_end[3],
    { "*/}" }
  )
  vim.api.nvim_buf_set_text(
    buf,
    start_row,
    s_start[3] - 1,
    start_row,
    s_start[3] - 1,
    { "{/*" }
  )

  -- NOTE: I need to escape back to normal mode.
  local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(keys, "v", true)
end

comment.binds = {
  {
    "gc",
    function()
      return require("Comment.api").call("toggle.linewise", "g@")()
    end,
    -- [[<cmd>lua require("Comment.api").api.call('toggle.linewise', 'g@')]],
    name = "comment motion",
   options = { expr = true },
  },
  {
    "gc",
    [[<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<cr>]],
    name = "comment line",
    mode = "v",
  },
  {
    "gb",
    [[<esc><cmd>lua require("Comment.api").toggle.blockwise(vim.fn.visualmode())<cr>]],
    name = "comment block",
    mode = "v",
  },
  {
    "gcc",
    [[<cmd>lua require("Comment.api").toggle.linewise.current()<cr>]],
    name = "comment line", --
  },
  {
    "gca",
    [[<cmd>lua require("Comment.api").insert.linewise.eol()<cr>]],
    name = "comment end of line",
  },
  {
    "gx",
    function()
      surround_visual_selection_with_jsx_comment()
    end,
    name = "hacky jsx comment",
    mode = "v",
  },
}

return comment
