local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
  s("str test init", {
    t("-- YYYYYY"),
  }),
  s("aaaa", {
    t("-- XXXXXX"),
  }),
  s("bbbb", {
    t("-- XXXXXX"),
  }),
}
