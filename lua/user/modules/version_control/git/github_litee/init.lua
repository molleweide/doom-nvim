local litee_gh = {}

-- TODO: !!! It's highly recommended to use gh.nvim with either fzf.lua or
-- telescope to override vim.ui.select. If you use telescope, it will work out
-- of the box. If you want to use fzf.lua, add the following snippet to your
-- config: vim.cmd("FzfLua register_ui_select")

litee_gh.requires_modules = { "molleweide.lib.litee" }

litee_gh.settings = {}

litee_gh.packages = {
  ["gh.nvim"] = {
    "ldelossa/gh.nvim",
  },
}

litee_gh.configs = {}

litee_gh.configs["gh.nvim"] = function()
  require("litee.gh").setup({
    -- deprecated, around for compatability for now.
    jump_mode = "invoking",
    -- remap the arrow keys to resize any litee.nvim windows.
    map_resize_keys = false,
    -- do not map any keys inside any gh.nvim buffers.
    disable_keymaps = false,
    -- the icon set to use.
    icon_set = "default",
    -- any custom icons to use.
    icon_set_custom = nil,
    -- whether to register the @username and #issue_number omnifunc completion
    -- in buffers which start with .git/
    git_buffer_completion = true,
    -- defines keymaps in gh.nvim buffers.
    keymaps = {
      -- when inside a gh.nvim panel, this key will open a node if it has
      -- any futher functionality. for example, hitting <CR> on a commit node
      -- will open the commit's changed files in a new gh.nvim panel.
      open = "<CR>",
      -- when inside a gh.nvim panel, expand a collapsed node
      expand = "zo",
      -- when inside a gh.nvim panel, collpased and expanded node
      collapse = "zc",
      -- when cursor is over a "#1234" formatted issue or PR, open its details
      -- and comments in a new tab.
      goto_issue = "gd",
      -- show any details about a node, typically, this reveals commit messages
      -- and submitted review bodys.
      details = "d",
      -- inside a convo buffer, submit a comment
      submit_comment = "<C-s>",
      -- inside a convo buffer, when your cursor is ontop of a comment, open
      -- up a set of actions that can be performed.
      actions = "<C-a>",
      -- inside a thread convo buffer, resolve the thread.
      resolve_thread = "<C-r>",
      -- inside a gh.nvim panel, if possible, open the node's web URL in your
      -- browser. useful particularily for digging into external failed CI
      -- checks.
      goto_web = "gx",
    },
  })
end

litee_gh.binds = {
  {
    "<leader>g",
    name = "+git",
    {
      {
        "h",
        name = "+gh",
        {
          {
            "c",
            name = "Commits",
            {
              { "c", "<cmd>GHCloseCommit<cr>", name = "Close" },
              { "e", "<cmd>GHExpandCommit<cr>", name = "Expand" },
              { "o", "<cmd>GHOpenToCommit<cr>", name = "Open To" },
              { "p", "<cmd>GHPopOutCommit<cr>", name = "Pop Out" },
              { "z", "<cmd>GHCollapseCommit<cr>", name = "Collapse" },
            },
          },
          {
            "i",
            name = "+Issues",
            {
              { "p", name = "<cmd>GHPreviewIssue<cr>", "Preview" },
            },
          },
          {
            "l",
            name = "+Litee",
            {
              { "t", name = "<cmd>LTPanel<cr>", "Toggle Panel" },
            },
          },
          {
            "r",
            name = "+Review",
            {
              { "b", "<cmd>GHStartReview<cr>", name = "Begin" },
              { "c", "<cmd>GHCloseReview<cr>", name = "Close" },
              { "d", "<cmd>GHDeleteReview<cr>", name = "Delete" },
              { "e", "<cmd>GHExpandReview<cr>", name = "Expand" },
              { "s", "<cmd>GHSubmitReview<cr>", name = "Submit" },
              { "z", "<cmd>GHCollapseReview<cr>", name = "Collapse" },
            },
          },
          {
            "p",
            name = "+Pull Request",
            {
              { "c", "<cmd>GHClosePR<cr>", name = "Close" },
              { "d", "<cmd>GHPRDetails<cr>", name = "Details" },
              { "e", "<cmd>GHExpandPR<cr>", name = "Expand" },
              { "o", "<cmd>GHOpenPR<cr>", name = "Open" },
              { "p", "<cmd>GHPopOutPR<cr>", name = "PopOut" },
              { "r", "<cmd>GHRefreshPR<cr>", name = "Refresh" },
              { "t", "<cmd>GHOpenToPR<cr>", name = "Open To" },
              { "z", "<cmd>GHCollapsePR<cr>", name = "Collapse" },
            },
          },
          {
            "t",
            name = "+Threads",
            {
              { "c", "<cmd>GHCreateThread<cr>", name = "Create" },
              { "n", "<cmd>GHNextThread<cr>", name = "Next" },
              { "t", "<cmd>GHToggleThread<cr>", name = "Toggle" },
            },
          },
        },
      },
    },
  },
}

return litee_gh
