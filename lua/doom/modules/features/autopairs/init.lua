local autopairs = {}

autopairs.settings = {
  --     disable_filetype = { "TelescopePrompt", "spectre_panel" }
  --     disable_in_macro = true  -- disable when recording or executing a macro
  --     disable_in_visualblock = false -- disable when insert after visual block mode
  --     disable_in_replace_mode = true
  --     ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=]
  enable_afterquote = true,
  enable_check_bracket_line = true,
  enable_moveright = true,
  --     enable_bracket_in_quote = true --
  --     enable_abbr = false -- trigger abbreviation
  --     break_undo = true -- switch for basic rule break undo sequence
  --     check_ts = false
  --     map_cr = true
  --     map_bs = true  -- map the <BS> key
  --     map_c_h = false  -- Map the <C-h> key to delete a pair
  --     map_c_w = false -- map <c-w> to delete a pair if possible
}

-- https://github.com/cohama/lexima.vim

autopairs.packages = {
  ["nvim-autopairs"] = {
    "windwp/nvim-autopairs",
    -- commit = "f00eb3b766c370cb34fdabc29c760338ba9e4c6c",
    event = "InsertEnter",
  },
}

autopairs.configs = {}
autopairs.configs["nvim-autopairs"] = function()
  require("nvim-autopairs").setup(
    vim.tbl_deep_extend("force", doom.features.autopairs.settings, { check_ts = true })
  )
end

autopairs.binds = {
  "<leader>",
  name = "+prefix",
  {
    {
      "t",
      name = "+tweak",
      {
        {
          "p",
          function()
            local autopairs_plugin = require("nvim-autopairs")
            if autopairs_plugin.state.disabled then
              autopairs_plugin.enable()
            else
              autopairs_plugin.disable()
            end
          end,
          name = "Toggle autopairs",
        },
      },
    },
  },
}
return autopairs
