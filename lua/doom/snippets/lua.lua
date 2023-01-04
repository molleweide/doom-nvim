local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s("xxx", t("bbb")),
  s("doom_plugins_add_simple", {
    t("{ '"),
    i(1, "plugin_name"),
    t("' },"),
  }),
  s("doom_user_binding", {
    t("{ '"),
    i(1, "mode"),
    t("', '"),
    i(2, "binding"),
    t("', '"),
    i(3, "command"),
    t("', '"),
    i(4, "option"),
    t("'},"),
  }),
  s("doom_map_oneline", {
    t('mappings.map( "'),
    i(1, "mode"),
    t('", "'),
    i(2, "mapping"),
    t('", "'),
    i(3, "command"),
    t('", "'),
    i(4, "options"),
    t('", "'),
    i(5, "category"),
    t('", "'),
    i(6, "id"),
    t('", "'),
    i(7, "desrc"),
    t('" )'),
  }),
  s("doom_map_multline", {
    t({ "mappings.map(", '\t"' }),
    i(1, "mode"),
    t({ '",', '\t"' }),
    i(2, "mapping"),
    t({ '",', '\t"' }),
    i(3, "command"),
    t({ '",', '\t"' }),
    i(4, "options"),
    t({ '",', '\t"' }),
    i(5, "category"),
    t({ '",', '\t"' }),
    i(6, "id"),
    t({ '",', '\t"' }),
    i(7, "desrc"),
    t({ '",', "\t" }),
    t(")"),
  }),

  --
  -- DOOM MODULE SETTINGS -----------------------------------------------------
  --

  --
  -- DOOM MODULE PACKAGES -----------------------------------------------------
  --

  --
  -- DOOM MODULE CONFIGS ------------------------------------------------------
  --

  --
  -- DOOM MODULE CMDS ---------------------------------------------------------
  --

  --
  -- DOOM MODULE AUTOCMDS -----------------------------------------------------
  --

  --
  -- DOOM BINDS ---------------------------------------------------------------
  --

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
