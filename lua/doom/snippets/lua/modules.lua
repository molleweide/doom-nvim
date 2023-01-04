local ls = require("luasnip")
local s = ls.snippet
-- local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- TODO: USE TREESITTER TO GET THE MODULE NAME

  --
  -- DOOM MODULE REQUIRES -----------------------------------------------------
  --

  s(
    "doom_requires_modules",
    fmt([[{{ {}.requires_modules = {{ "{}" }}]], {
      i(1, "mod name"),
      i(2, "req mods list"),
    })
  ),

  --
  -- DOOM MODULE SETTINGS -----------------------------------------------------
  --

  s(
    "doom_module_settings",
    fmt(
      [[
    {}.settings = {{
      {}
    }}
    ]],
      {
        i(1, "mod name"),
        i(2, "settings"),
      }
    )
  ),


  -- -- TODO: table key = {{ {} }}
  --         this should also be a choice node so that you can
  --         cycle through relevant key/value pair types
  --         key -> {} or ["{}"]
  --         val -> {{}} or function() end
  --
  --    NOTE: this snippet can allow you to stay inside of a snippet
  --    throughout the whole composing of a table which is pretty fucking
  --    neat.
  -- s(
  --   "doom_key_val",
  --   fmt(
  --     [[
  --   ["{}"] = {{
  --     "{}"
  --   }}
  --   ]],
  --     {
  --       i(1, "pkg key"),
  --       i(2, "pkg repo string"),
  --     }
  --   )
  -- ),
  s(
    "key_val_pair",
    fmt(
      [[ {} = {}, ]],
      {
        i(1, "key"),
        i(2, "val"),
      }
    )
  ),



  --
  -- DOOM MODULE PACKAGES -----------------------------------------------------
  --

  s(
    "doom_module_packages",
    fmt(
      [[
    {}.packages = {{
      {}
    }}
    ]],
      {
        i(1, "mod name"),
        i(2, "packages"),
      }
    )
  ),

  s(
    "doom_module_pkg_single",
    fmt(
      [[
    ["{}"] = {{
      "{}"
    }}
    ]],
      {
        i(1, "pkg key"),
        i(2, "pkg repo string"),
      }
    )
  ),

  --
  -- DOOM MODULE CONFIGS ------------------------------------------------------
  --

  s(
    "doom_module_config_single",
    fmt(
      [[
    {}.configs["{}"] = function()
      require("{}").setup({})
    end
    ]],
      {
        i(1, "mod_name"),
        i(2, "package_name"),
        i(3, "setup"),
        i(4, "opts"),
      }
    )
  ),

  --
  -- DOOM MODULE CMDS ---------------------------------------------------------
  --

  s(
    "doom_module_cmds_table",
    fmt(
      [[
    {}.cmds = {{
      {}
    }}
    ]],
      {
        i(1, "mod name"),
        i(2, "cmds insert"),
      }
    )
  ),

  s(
    "doom_cmd_single",
    fmt(
      [[ {{ "{}", function()
        {}
      end}} ]],
      {
        i(1, "cmd_name"),
        i(2, "action_body"),
      }
    )
  ),


  --
  -- DOOM MODULE AUTOCMDS -----------------------------------------------------
  --

  s(
    "doom_module_autocmds_table",
    fmt(
      [[
    {}.autocmds = {{
      {}
    }}
    ]],
      {
        i(1, "mod name"),
        i(2, "autocmds insert"),
      }
    )
  ),

  s(
    "doom_autocmd_single",
    fmt(
      [[ {{ "{}", "{}", function()
        {}
      end}} ]],
      {
        i(1, "event"),
        i(2, "pattern"),
        i(3, "action_body"),
      }
    )
  ),


  --
  -- DOOM BINDS ---------------------------------------------------------------
  --

  -- binds table
  s(
    "doom_module_binds_table",
    fmt(
      [[
    {}.binds = {{
      {}
    }}
    ]],
      {
        i(1, "mod name"),
        i(2, "binds insert"),
      }
    )
  ),

  -- bind leaf
  s(
    "doom_binds_leaf",
    fmt([[ {{ "{}", {}, name = "{}" }}, ]], {
      i(1, "bind_seq"),
      i(2, "bind_command"),
      i(3, "bind_name"),
    })
  ),

  -- regular branch
  s(
    "doom_binds_branch_regular",
    fmt(
      [[{{
        "{}",
        {{
          {}
        }},
      }},]],
      {
        i(1, "branch_sequence"),
        i(3, "branch_inner"),
      }
    )
  ),

  -- leader branch regular
  s(
    "doom_binds_branch_leader",
    fmt(
      [[{{
        "{}",
        name = "+{}",
        {{
          {}
        }},
      }},]],
      {
        i(1, "branch_sequence"),
        i(2, "branch_name"),
        i(3, "branch_inner"),
      }
    )
  ),

  -- leader branch prefix
  s(
    "doom_binds_branch_leader_prefix",
    fmt(
      [[{{
        "<leader>",
        name = "+prefix",
        {{
          {}
        }},
      }},]],
      {
        i(1, "insert_bind"),
      }
    )
  ),
}
