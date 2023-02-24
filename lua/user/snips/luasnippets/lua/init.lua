local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

-- https://github.com/L3MON4D3/LuaSnip/wiki/Cool-Snippets#lua---new-module-function
return {
  s("str test init", {
    t("-- ABCDS"),
  }),
  s("dummy", {
    t("-- dummy"),
  }),
  s("aaaa", {
    t("-- XXXXXX"),
  }),
  s("bbbb", {
    t("-- XXXXXX"),
  }),

  -- s(
  --   'mfn',
  --   c(1, {
  --     fmt('function {}.{}({})\n  {}\nend', {
  --       f(get_returned_mod_name, {}),
  --       i(1),
  --       i(2),
  --       i(3),
  --     }),
  --     fmt('function {}:{}({})\n  {}\nend', {
  --       f(get_returned_mod_name, {}),
  --       i(1),
  --       i(2),
  --       i(3),
  --     }),
  --   })
  -- )

  -- TODO: modify this to generate endless key value pairs in a table.
  -- https://github.com/L3MON4D3/LuaSnip/wiki/Cool-Snippets#latex---endless-list

  -- TODO: BOX COMMENTS
  -- https://github.com/L3MON4D3/LuaSnip/wiki/Cool-Snippets#box-comment-like-ultisnips
}
