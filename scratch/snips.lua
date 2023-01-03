local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local parse = "xxx"
local trigger = "xxx"

---
return {
  { "abc", { t("abcdefghijklmnopqrstuvwxyz") } },
  {
    "ccc",
    { t("abcdefghijklmnopqrstuvwxyz"), t("aaaaaa"), t("sssssss"), t("12345678") },
    {},
    ls.parser.parse_snippet,
  },

  { "ctodo", { t("-- TODO: "), i(1, "todo_body") } },
  { "todo", { t("TODO: "), i(1, "todo_body") } },

  {
    "fn",
    {
      d(6, jdocsnip, { 2, 4, 5 }),
      t({ "", "" }),
      c(1, {
        t("public "),
        t("private "),
      }),
      c(2, {
        t("void"),
        t("String"),
        t("char"),
        t("int"),
        t("double"),
        t("boolean"),
        i(nil, ""),
      }),
      t(" "),
      i(3, "myFunc"),
      t("("),
      i(4),
      t(")"),
      c(5, {
        t(""),
        sn(nil, {
          t({ "", " throws " }),
          i(1),
        }),
      }),
      t({ " {", "\t" }),
      i(0),
      t({ "", "}" }),
    },
  },
  { "cfix", { t("-- FIX: "), i(1, "fix_body") } },
  { "fix", { t("FIX: "), i(1, "fix_body") } },
  {
    "lspsyn",
    "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}",
    {},
    "ls.parser.parse_snippet",
  },
  {
    "fmt2",
    fmt(
      [[
		foo({1}, {3}) {{
			return {2} * {4}
		}}
		  ]],
      {
        i(1, "x"),
        rep(1),
        i(2, "y"),
        rep(2),
      }
    ),
  },

  {
    { trig = "te", wordTrig = false },
    "${1:cond} ? ${2:true} : ${3:false}",
    {},
    ls.parser.parse_snippet,
  },
  { "chack", { t("-- HACK: "), i(1, "hack_body") } },
  { "hack", { t("HACK: "), i(1, "hack_body") } },

  { "cwarn", { t("-- WARN: "), i(1, "warn_body") } },
  { "warn", { t("WARN: "), i(1, "warn_body") } },

  { "cperf", { t("-- PERF: "), i(1, "perf_body") } },
  { "perf", { t("PERF: "), i(1, "perf_body") } },

  { "cnote", { t("-- NOTE: "), i(1, "note_body") } },
  { "note", { t("NOTE: "), i(1, "note_body") } },
}
