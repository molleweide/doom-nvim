local rk_definitions = "~/reaper/packages/reaper-keys/definitions/"

local rk = {}

--
-- TODO: continue work on DUI and then reuse it for RK.
--  create a UI pipeline with telescope that allows me to create new action
--  bindings in RK
--  select
--    domain:     global|main|midi
--
--    action_type:  command             (domain restricts possible action_types)
--                  timeline_operator
--                  timeline_selector
--                  ....
--
--    key_sequence:       (show virtual text if there is a clash, ie. treesitter..)
--
--    actions: list all possible actions in picker...
--

-- -- https://github.com/NlGHT/Night-REAPER-Scripts/blob/master/Scripting%20Tools/GetReaScriptAPI
-- --
-- -- https://github.com/NlGHT/Night-REAPER-Scripts/blob/master/Scripting%20Tools/MakeEELSnippets
-- --
-- -- https://github.com/NlGHT/vim-eel
--
-- rk.cmds = {}
--
-- rk.autocmds = {}
--
--
-- -- quickly get to the reaper keys binds file
--
-- --

rk.binds = {
  {
    "<leader>",
    name = "+prefix",
    {
      {
        "R",
        name = "+reaper",
        {
          {
            "A",
            "<cmd>e " .. rk_definitions .. "defaults/actions.lua" .. "<CR>",
          },
          {
            "R",
            function()
              require("telescope.builtin").find_files({
                cwd = rk_definitions,
              })
            end,
            name = "find reaper definitions",
          },

          {
            "u",
            name = "+user",
            {
              { "a", "<cmd>e " .. rk_definitions .. "actions.lua" .. "<CR>" },
              { "b", "<cmd>e " .. rk_definitions .. "bindings.lua" .. "<CR>" },
              { "c", "<cmd>e " .. rk_definitions .. "config.lua" .. "<CR>" },
            },
          },

          -- {
          --   "g",
          --   name = "+go",
          --   {
          --     { "D", "<cmd>e " .. paths.doom_log_path .. "<CR>" },
          --     -- { "N", "<cmd>e " .. paths.notes_rndm .. "<CR>" },
          --     { "S", "<cmd>e " .. paths.conf_skhd .. "<CR>" },
          --     { "a", "<cmd>e " .. paths.conf_alac .. "<CR>" },
          --     { "e", "<cmd>e " .. paths.conf_setup .. "<CR>" },
          --     { "g", "<cmd>e " .. paths.aliases_git .. "<CR>" },
          --     { "m", "<cmd>e " .. paths.conf_tnx_main .. "<CR>" },
          --     -- { "n", "<cmd>e " .. paths.notes_todo .. "<CR>" },
          --     { "s", "<cmd>e " .. paths.conf_surf .. "<CR>" },
          --     { "t", "<cmd>e " .. paths.conf_tmux .. "<CR>" },
          --     { "x", "<cmd>e " .. paths.conf_scim .. "<CR>" },
          --     { "y", "<cmd>e " .. paths.conf_yabai .. "<CR>" },
          --     { "z", "<cmd>e " .. paths.aliases_zsh .. "<CR>" },
          --   },
          -- }, -- moll > go
        },
      },
    },
  },
}

return rk
