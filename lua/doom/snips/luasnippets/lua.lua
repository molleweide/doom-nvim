local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- function used with `ls` below.
local rec_ls = function()
  return sn(nil, {
    c(1, {
      -- important!! Having the sn(...) as the first choice will cause infinite recursion.
      t({ "" }),
      -- The same dynamicNode as in the snippet (also note: self reference).
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    }),
  })
end

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

  -- NOTE: Lua - New module function
  -- Use Treesitter to determine the name of the variable returned from the module
  --   and use that as the function's parent, with a choice node to swap between
  -- static function (Module.fn_name) vs. instance method (Module:fn_name) syntax.

  s(
    "mfn",
    c(1, {
      fmt("function {}.{}({})\n  {}\nend", {
        f(get_returned_mod_name, {}),
        i(1),
        i(2),
        i(3),
      }),
      fmt("function {}:{}({})\n  {}\nend", {
        f(get_returned_mod_name, {}),
        i(1),
        i(2),
        i(3),
      }),
    })
  ),

  -- NOTE: Lua - New module function
  --    ⚠️ This is pretty hackish, and is just meant to how far luasnip can be pushed.
  --    For actual use, the external update ( DynamicNode )[ https://github.com/L3MON4D3/LuaSnip/wiki/Misc#dynamicnode-with-user-input ]
  --    is more capable, snippets are more readable, and its behaviour in is
  --    plain better (eg. doesn't lead to deeply nested snippets) Of course,
  --    this is just a recommendation :)
  --    >> This snippet first expands to
  --      \begin{itemize}
  --      	\item $1
  --      \end{itemize}
  --    upon jumping into the dynamicNode and changing the choice, another
  --    dynamicNode (and with it, \item) will be inserted. As the dynamicNode
  --    is recursive, it's possible to insert as many \items' as desired.
  --
  --   FIX: tweak into a infinite lua table snippet

  s("ls", {
    t({ "\\begin{itemize}", "\t\\item " }),
    i(1),
    d(2, rec_ls, {}),
    t({ "", "\\end{itemize}" }),
    i(0),
  }),
}
