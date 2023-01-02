local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	lua = {
	    s("default_test", { t("-- default test") }),
	}
}
