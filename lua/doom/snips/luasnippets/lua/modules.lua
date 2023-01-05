local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")

-- TODO: USE TREESITTER TO GET THE MODULE NAME
local function reused_func(_, _, user_arg1)
  return user_arg1
end

return {
  s({
    trig = "st",
    name = "SNIP_TEST",
    dscr = "trying out as many luasnip nodes as possible",
    wordTrig = true, -- how does this work if `false`?
    priority = 10000,
  }, {
    t("(s1): finish here: "),
    i(0),
    t("::: [snip test] -> "),
    i(1, "insertion_point_one", "with_line_two"),
    t("", ""),
    sn(2, {
      t("(s2): "),
      i(1, "Second jump"),
      t(" : "),
      i(2, "Third jump but second inside of the `sn` node"),
      t(""), -- new line?
      t("xxx"), -- new line?
      t(""), -- new line?
      f(reused_func, {}, {
        user_args = { "func node text" },
      }),
      f(reused_func, {}, {
        user_args = { "func node different text" },
      }),
    }),
  }, {}),

  -- ls.parser.parse_snippet({ name = "NUM", trig = "%d", regTrig = true }, "A Number!!"),

  s(
    { trig = "b(%d)", regTrig = true },
    f(function(_, snip)
      return "Captured Text: " .. snip.captures[1] .. "."
    end, {})
  ),

	s({ trig = "trafo(%d+)", regTrig = true }, {
		-- env-variables and captures can also be used:
		l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
	}),
  --
  -- USEFUL DOOM CHOICES TEST
  --

  -- testing choice nodes
  s(
    { trig = "dv", "doom_vars" },
    c(1, {
      t("doom.modules.molleweide"),
      t("doom.modules.core"),
      t("doom.modules.features"),
      t("doom.modules.langs"),
    })
  ),

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
    fmt([[ {} = {}, ]], {
      i(1, "key"),
      i(2, "val"),
    })
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
